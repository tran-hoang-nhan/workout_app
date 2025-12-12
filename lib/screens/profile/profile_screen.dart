import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import 'edit_profile_screen.dart';
import 'widgets/profile_header_card.dart';
import 'widgets/profile_stats_section.dart';
import 'widgets/profile_menu_button.dart';
import 'widgets/profile_logout_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      body: SafeArea(
        child: userAsync.when(
          loading: () => Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                CircularProgressIndicator(color: AppColors.primary),
                SizedBox(height: AppSpacing.lg),
                Text(
                  'Đang tải...',
                  style: TextStyle(color: AppColors.grey, fontSize: AppFontSize.md),
                ),
              ],
            ),
          ),
          error: (err, stack) => Center(
            child: Text('Lỗi: $err', style: const TextStyle(color: AppColors.danger)),
          ),
          data: (user) {
            if (user == null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.person_off_outlined, size: 80, color: AppColors.grey),
                    SizedBox(height: AppSpacing.lg),
                    Text('Vui lòng đăng nhập', style: TextStyle(fontSize: AppFontSize.lg, color: AppColors.grey)),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.lg).copyWith(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Cá nhân',
                    style: TextStyle(
                      fontSize: AppFontSize.xxxl,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
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
                  const SizedBox(height: AppSpacing.xl),
                  ProfileMenuButton(
                    title: 'Cài đặt',
                    description: 'Quản lý tài khoản',
                    icon: Icons.settings,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ProfileMenuButton(
                    title: 'Thông báo',
                    description: 'Nhắc nhở và cập nhật',
                    icon: Icons.notifications,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.md),
                  ProfileMenuButton(
                    title: 'Trợ giúp',
                    description: 'FAQ và hỗ trợ',
                    icon: Icons.help,
                    onTap: () {},
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  ProfileLogoutButton(
                    onLogoutConfirmed: () async {
                      try {
                        await ref.read(authServiceProvider).signOut();
                        if (context.mounted) {
                          ref.invalidate(authStateProvider);
                          Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
                        }
                      } catch (e) {
                        debugPrint('Logout error: $e');
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Lỗi đăng xuất: $e')),
                          );
                        }
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
