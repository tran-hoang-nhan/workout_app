import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class ProfileLogoutButton extends StatelessWidget {
  final VoidCallback onLogoutConfirmed;

  const ProfileLogoutButton({
    super.key,
    required this.onLogoutConfirmed,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
          onLogoutConfirmed();
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
    );
  }
}
