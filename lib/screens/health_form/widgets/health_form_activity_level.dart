import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';

class HealthFormActivityLevel extends ConsumerWidget {
  const HealthFormActivityLevel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activityLevel = ref.watch(
      healthFormProvider.select((s) => s.activityLevel),
    );
    final notifier = ref.read(healthFormProvider.notifier);

    final levels = [
      ('sedentary', 'Ít vận động', 'Ít hoặc không tập luyện'),
      ('lightly_active', 'Nhẹ nhàng', '1-3 ngày/tuần'),
      ('moderately_active', 'Trung bình', '3-5 ngày/tuần'),
      ('very_active', 'Rất tích cực', '6-7 ngày/tuần'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mức độ vận động',
            style: TextStyle(
              fontSize: AppFontSize.lg,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...levels.map(((level) {
            final value = level.$1;
            final label = level.$2;
            final desc = level.$3;
            final isSelected = activityLevel == value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: GestureDetector(
                onTap: () => notifier.setActivityLevel(value),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary.withValues(alpha: 0.05)
                        : AppColors.white,
                    border: Border.all(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.cardBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.primary.withValues(alpha: 0.1),
                              blurRadius: 4,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                color: isSelected
                                    ? AppColors.primary
                                    : AppColors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: AppFontSize.md,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              desc,
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: AppFontSize.sm,
                                fontWeight: isSelected
                                    ? FontWeight.w500
                                    : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                        const Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 24,
                        )
                      else
                        const Icon(
                          Icons.circle_outlined,
                          color: AppColors.cardBorder,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          })),
        ],
      ),
    );
  }
}
