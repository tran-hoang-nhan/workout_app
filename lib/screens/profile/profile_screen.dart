import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../utils/app_error.dart';
import '../../widgets/loading_animation.dart';
import '../edit_profile/edit_profile_screen.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/profile_stats_section.dart';
import 'widgets/profile_menu_button.dart';
import 'widgets/profile_logout_button.dart';
import 'widgets/change_password_dialog.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: userAsync.when(
          loading: () =>
              const Center(child: AppLoading(message: 'Đang tải thông tin...')),
          error: (e, st) => Center(
            child: Text(
              e is AppError ? e.userMessage : 'Lỗi: $e',
              style: const TextStyle(color: AppColors.danger),
            ),
          ),
          data: (user) {
            if (user == null) {
              return const Center(child: Text('Vui lòng đăng nhập'));
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                AppSpacing.xl,
                AppSpacing.lg,
                120,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Cá nhân',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black,
                      letterSpacing: -1,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ProfileHeaderCard(
                    user: user,
                    onEditTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  const ProfileStatsSection(),
                  const SizedBox(height: 32),
                  const Text(
                    'Cài đặt & Hỗ trợ',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ProfileMenuButton(
                    title: 'Đổi mật khẩu',
                    description: 'Cập nhật lại mật khẩu bảo mật',
                    icon: Icons.lock_outline_rounded,
                    onTap: () => _showChangePasswordDialog(context, ref),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ProfileMenuButton(
                    title: 'Thông báo',
                    description: 'Nhắc nhở luyện tập hàng ngày',
                    icon: Icons.notifications_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ProfileMenuButton(
                    title: 'Trợ giúp',
                    description: 'Trung tâm hỗ trợ và FAQ',
                    icon: Icons.help_outline_rounded,
                    onTap: () {},
                  ),
                  const SizedBox(height: 32),
                  ProfileLogoutButton(
                    onLogoutConfirmed: () async {
                      try {
                        await ref
                            .read(authControllerProvider.notifier)
                            .signOut();
                        if (context.mounted) {
                          ref.invalidate(currentUserIdProvider);
                          ref.invalidate(currentUserProvider);
                          Navigator.of(
                            context,
                          ).pushNamedAndRemoveUntil('/', (route) => false);
                        }
                      } catch (e) {
                        debugPrint('Logout error: $e');
                      }
                    },
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Future<void> _showChangePasswordDialog(
    BuildContext context,
    WidgetRef ref,
  ) async {
    return showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }
}
