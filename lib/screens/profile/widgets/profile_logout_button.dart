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
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
        decoration: BoxDecoration(
          color: AppColors.bgLight,
          border: Border.all(color: Colors.black.withValues(alpha: 0.1)),
          borderRadius: BorderRadius.circular(AppBorderRadius.md),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: const Color(0xFFEF4444).withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppBorderRadius.sm),
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
            Icon(Icons.chevron_right, color: Colors.grey.shade400, size: 20),
          ],
        ),
      ),
    );
  }
}
