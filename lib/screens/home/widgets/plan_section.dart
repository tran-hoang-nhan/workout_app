import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class PlanSection extends StatelessWidget {
  const PlanSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Kế hoạch hôm nay',
              style: TextStyle(
                fontSize: AppFontSize.lg,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Row(
                children: [
                  Text(
                    'Xem tất cả',
                    style: TextStyle(
                      fontSize: AppFontSize.sm,
                      color: Color(0xFFFF7F00),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(width: AppSpacing.xs),
                  Icon(
                    Icons.chevron_right,
                    color: Color(0xFFFF7F00),
                    size: 18,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFFFF7F00), Color(0xFFFF0000)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
          ),
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Buổi tập tiếp theo',
                          style: TextStyle(
                            fontSize: AppFontSize.sm,
                            color: Color(0xFFFFE4B5),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        const Text(
                          'Full Body Workout',
                          style: TextStyle(
                            fontSize: AppFontSize.xxl,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: [
                            const Icon(
                              Icons.schedule,
                              size: 16,
                              color: Color(0xFFFFE4B5),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            const Text(
                              '45 phút',
                              style: TextStyle(
                                fontSize: AppFontSize.sm,
                                color: Color(0xFFFFE4B5),
                              ),
                            ),
                            const SizedBox(width: AppSpacing.lg),
                            const Icon(
                              Icons.flag_outlined,
                              size: 16,
                              color: Color(0xFFFFE4B5),
                            ),
                            const SizedBox(width: AppSpacing.xs),
                            const Text(
                              'Trung bình',
                              style: TextStyle(
                                fontSize: AppFontSize.sm,
                                color: Color(0xFFFFE4B5),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(AppBorderRadius.full),
                    ),
                    child: const Icon(
                      Icons.local_fire_department,
                      color: AppColors.white,
                      size: 28,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: const Color(0xFFFF7F00),
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    ),
                  ),
                  onPressed: () {},
                  child: const Text(
                    'Bắt đầu ngay',
                    style: TextStyle(
                      fontSize: AppFontSize.md,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
