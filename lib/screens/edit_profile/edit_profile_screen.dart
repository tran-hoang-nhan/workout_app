import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/avatar_provider.dart';
import '../../providers/profile_provider.dart';
import '../../services/profile_service.dart';
import '../../utils/ui_utils.dart';
import '../../widgets/loading_animation.dart';
import 'widgets/edit_profile_avatar.dart';
import 'widgets/edit_profile_bottom_bar.dart';
import 'widgets/edit_profile_form_components.dart';
import 'widgets/edit_profile_gender_selector.dart';
import 'widgets/edit_profile_goal_selector.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  String? _gender;
  String? _goal;
  bool _isSaving = false;
  bool _isDataLoaded = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _ageController = TextEditingController();
  }

  void _loadUserData() {
    final user = ref.read(fullUserProfileProvider).value;
    if (user != null && !_isDataLoaded) {
      setState(() {
        _nameController.text = user.fullName ?? '';
        _ageController.text = user.age?.toString() ?? '';
        _goal = user.goal;
        _gender = user.gender;
        _isDataLoaded = true;
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUploadAvatar() async {
    try {
      await ref.read(profileServiceProvider).pickAndUploadAvatar();
      if (!mounted) return;
      context.showSuccess('Cập nhật avatar thành công!');
    } catch (e) {
      if (!mounted) return;
      context.showError('Lỗi: $e');
    }
  }

  Future<void> _removeAvatar() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa avatar'),
        content: const Text('Bạn có chắc muốn xóa avatar?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Xóa'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        await ref.read(profileServiceProvider).removeAvatar();
        if (!mounted) return;
        context.showSuccess('Xóa avatar thành công!');
      } catch (e) {
        if (!mounted) return;
        context.showError('Lỗi: $e');
      }
    }
  }

  Future<void> _saveProfile() async {
    final user = ref.read(fullUserProfileProvider).value;
    if (user == null) return;

    setState(() => _isSaving = true);

    try {
      await ref.read(profileServiceProvider).saveProfile(
        userId: user.id,
        fullName: _nameController.text,
        gender: _gender,
        age: int.tryParse(_ageController.text),
        goal: _goal,
      );

      if (!mounted) return;
      context.showSuccess('Đã cập nhật hồ sơ thành công!');
      ref.invalidate(fullUserProfileProvider);
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      context.showError('Lỗi: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(fullUserProfileProvider);
    final user = userAsync.value;

    // Load data khi có sẵn
    if (user != null && !_isDataLoaded) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _loadUserData();
      });
    }

    // Sync name controller if not focused
    if (user != null && !_nameController.selection.isValid) {
      if (_nameController.text != user.fullName) {
        _nameController.text = user.fullName ?? '';
      }
    }

    final avatarState = ref.watch(avatarControllerProvider);
    final isUploading = avatarState.isLoading;
    final displayAvatarUrl = user?.avatarUrl ?? '';

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: userAsync.when(
        loading: () => const Center(child: AppLoading(message: 'Đang tải hồ sơ...')),
        error: (error, st) => Center(child: Text('Lỗi: $error')),
        data: (user) {
          if (user == null) {
            return const Center(child: Text('Vui lòng đăng nhập'));
          }

          return Column(
            children: [
              _buildHeader(context),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    AppSpacing.lg,
                    AppSpacing.lg,
                    100,
                  ),
                  child: Column(
                    children: [
                      EditProfileAvatar(
                        displayAvatarUrl: displayAvatarUrl,
                        isUploading: isUploading,
                        onPickImage: _pickAndUploadAvatar,
                        onRemoveImage: _removeAvatar,
                      ),
                      const SizedBox(height: 32),

                      const EditProfileSectionTitle(title: 'Thông tin cơ bản'),
                      EditProfileInfoCard(
                        children: [
                          EditProfileTextField(
                            label: 'Họ và tên',
                            controller: _nameController,
                            icon: Icons.person_outline_rounded,
                          ),
                          const Divider(
                            height: 32,
                            color: AppColors.cardBorder,
                          ),
                          EditProfileGenderSelector(
                            selectedGender: _gender,
                            onGenderChanged: (value) =>
                                setState(() => _gender = value),
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),
                      const EditProfileSectionTitle(title: 'Thông tin cá nhân'),
                      EditProfileInfoCard(
                        children: [
                          EditProfileTextField(
                            label: 'Tuổi',
                            controller: _ageController,
                            icon: Icons.cake_rounded,
                            keyboardType: TextInputType.number,
                          ),
                          const Divider(
                            height: 32,
                            color: AppColors.cardBorder,
                          ),
                          EditProfileGoalSelector(
                            selectedGoal: _goal,
                            onGoalChanged: (value) =>
                                setState(() => _goal = value),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: EditProfileBottomBar(
        isSaving: _isSaving,
        onSave: _saveProfile,
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 10,
        bottom: 10,
      ),
      decoration: const BoxDecoration(color: AppColors.bgLight),
      child: Row(
        children: [
          const SizedBox(width: 8),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
          ),
          const Expanded(
            child: Text(
              'Chỉnh sửa hồ sơ',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w900,
                color: AppColors.black,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(width: 48),
        ],
      ),
    );
  }
}
