import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/health_provider.dart';
import '../../utils/ui_utils.dart';
import 'widgets/health_form_header.dart';
import 'widgets/health_form_basic_stats.dart';
import 'widgets/health_form_conditions_list.dart';
import 'widgets/health_form_activity_level.dart';
import 'widgets/health_form_water_goal.dart';
import 'widgets/health_form_reminders.dart';
import 'widgets/health_form_diet_nutrition.dart';

class HealthFormUI extends ConsumerWidget {
  final TextEditingController injuryController;
  final TextEditingController conditionController;
  final TextEditingController allergyController;
  final VoidCallback? onClose;
  final bool isSaving;

  const HealthFormUI({
    super.key,
    required this.injuryController,
    required this.conditionController,
    required this.allergyController,
    this.onClose,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg).copyWith(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          HealthFormHeader(onClose: onClose),
          const SizedBox(height: AppSpacing.xl),

          const HealthFormBasicStats(),
          const SizedBox(height: AppSpacing.lg),

          HealthFormConditionsList(
            injuryController: injuryController,
            conditionController: conditionController,
          ),
          const SizedBox(height: AppSpacing.lg),

          const HealthFormActivityLevel(),
          const SizedBox(height: AppSpacing.lg),

          const HealthFormWaterGoal(),
          const SizedBox(height: AppSpacing.lg),

          const HealthFormReminders(),
          const SizedBox(height: AppSpacing.lg),

          HealthFormDietNutrition(allergyController: allergyController),
          const SizedBox(height: AppSpacing.xl),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving ? null : () => _handleSave(context, ref),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.greyLight,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                ),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
              child: Text(
                isSaving ? 'Đang lưu...' : 'Lưu Hồ Sơ',
                style: const TextStyle(
                  fontSize: AppFontSize.lg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSave(BuildContext context, WidgetRef ref) async {
    try {
      final formState = ref.read(healthFormProvider);
      await ref.read(
        saveHealthProfileProvider((
          height: formState.height,
          gender: null,
        )).future,
      );

      if (context.mounted) {
        context.showSuccess('Đã lưu thông tin sức khỏe thành công!');
        if (onClose != null) onClose!();
      }
    } catch (e) {
      if (context.mounted) {
        context.showError(e);
      }
    }
  }
}
