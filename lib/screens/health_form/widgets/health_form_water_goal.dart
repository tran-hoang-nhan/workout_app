import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';

class HealthFormWaterGoal extends ConsumerWidget {
  const HealthFormWaterGoal({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterIntake = ref.watch(
      healthFormProvider.select((s) => s.waterIntake),
    );
    final notifier = ref.read(healthFormProvider.notifier);

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
            'Mục tiêu uống nước (ml/ngày)',
            style: TextStyle(
              fontSize: AppFontSize.lg,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            key: const ValueKey('waterIntake'),
            initialValue: waterIntake.toString(),
            onChanged: (value) => notifier.setWaterIntake(
              (double.tryParse(value) ?? waterIntake.toDouble()),
            ),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.black),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: AppColors.greyLight.withValues(alpha: 0.3),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '≈ ${(waterIntake / 250).round()} ly nước',
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: AppFontSize.sm,
            ),
          ),
        ],
      ),
    );
  }
}
