import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';

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
                  // Profile Card
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF7F00), Color(0xFFFF0000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.person, size: 40, color: AppColors.white),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    user.fullName ?? 'User',
                                    style: const TextStyle(
                                      fontSize: AppFontSize.xl,
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.white,
                                    ),
                                  ),
                                  const SizedBox(height: AppSpacing.sm),
                                  Row(
                                    children: [
                                      const Icon(Icons.mail_outline, size: 16, color: Colors.white70),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          user.email,
                                          style: const TextStyle(
                                            fontSize: AppFontSize.sm,
                                            color: Colors.white70,
                                          ),
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.edit, size: 20, color: AppColors.white),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildInfoCard('${user.height?.toStringAsFixed(1) ?? '0.0'} cm', 'Chiều cao'),
                            _buildInfoCard(user.goal ?? 'N/A', 'Mục tiêu'),
                            _buildInfoCard(user.gender ?? 'N/A', 'Giới tính'),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Stats Section
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0A1A3F),
                      border: Border.all(color: const Color(0xFF1A3A5F)),
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Tổng quan',
                          style: TextStyle(
                            fontSize: AppFontSize.lg,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        _buildStatRow('Tổng buổi tập', '0'),
                        const SizedBox(height: AppSpacing.md),
                        _buildStatRow('Tổng thời gian', '0h'),
                        const SizedBox(height: AppSpacing.md),
                        _buildStatRow('Calories đã đốt', '0k'),
                        const SizedBox(height: AppSpacing.md),
                        _buildStatRow('Chuỗi ngày', '0 ngày', isHighlight: true),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  // Menu Items
                  _buildMenuButton('Cài đặt', 'Quản lý tài khoản', Icons.settings),
                  const SizedBox(height: AppSpacing.md),
                  _buildMenuButton('Thông báo', 'Nhắc nhở và cập nhật', Icons.notifications),
                  const SizedBox(height: AppSpacing.md),
                  _buildMenuButton('Trợ giúp', 'FAQ và hỗ trợ', Icons.help),
                  const SizedBox(height: AppSpacing.xl),
                  // Logout Button
                  GestureDetector(
                    onTap: () async {
                      final confirmLogout = await showDialog<bool>(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: const Text('Đăng xuất'),
                          content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Hủy'),
                            ),
                            TextButton(
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Đăng xuất', style: TextStyle(color: Color(0xFFEF4444))),
                            ),
                          ],
                        ),
                      );

                      if (confirmLogout == true && context.mounted) {
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
                      }
                    },
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: const Color(0xFF0A1A3F),
                        border: Border.all(color: const Color(0xFF1A3A5F)),
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(AppBorderRadius.md),
                            ),
                            child: const Icon(Icons.logout, color: Color(0xFFEF4444), size: 20),
                          ),
                          const SizedBox(width: AppSpacing.md),
                          const Expanded(
                            child: Text(
                              'Đăng xuất',
                              style: TextStyle(
                                color: Color(0xFFEF4444),
                                fontWeight: FontWeight.bold,
                                fontSize: AppFontSize.md,
                              ),
                            ),
                          ),
                          const Icon(Icons.chevron_right, color: AppColors.grey),
                        ],
                      ),
                    ),
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

  Widget _buildInfoCard(String value, String label) {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm, horizontal: AppSpacing.xs),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: const TextStyle(
                fontSize: AppFontSize.md,
                fontWeight: FontWeight.bold,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            Text(
              label,
              style: const TextStyle(
                fontSize: AppFontSize.xs,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(color: AppColors.grey, fontSize: AppFontSize.md),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: AppFontSize.lg,
            fontWeight: FontWeight.bold,
            color: isHighlight ? const Color(0xFFFF7F00) : AppColors.white,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuButton(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1A3F),
        border: Border.all(color: const Color(0xFF1A3A5F)),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1A1A1A),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            child: Icon(icon, color: AppColors.grey, size: 20),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: AppFontSize.md,
                  ),
                ),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  description,
                  style: const TextStyle(
                    color: AppColors.grey,
                    fontSize: AppFontSize.sm,
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: AppColors.grey),
        ],
      ),
    );
  }
}
