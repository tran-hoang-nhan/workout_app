import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class ProgressHeader extends StatelessWidget {
  const ProgressHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tiến độ',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.black,
                letterSpacing: -1,
              ),
            ),
            Text(
              'Hành trình chinh phục mục tiêu của bạn',
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
