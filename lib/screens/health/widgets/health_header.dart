import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class HealthHeader extends StatelessWidget {
  final VoidCallback onEditTap;

  const HealthHeader({
    super.key,
    required this.onEditTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Sức khỏe',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Theo dõi các chỉ số sức khỏe của bạn',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
            ),
          ],
        ),
        GestureDetector(
          onTap: onEditTap,
          child: const Text(
            'Sửa hồ sơ',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
        ),
      ],
    );
  }
}
