import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';
import 'health_form_field_builder.dart';

class HealthFormReminders extends ConsumerWidget {
  const HealthFormReminders({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(healthFormProvider);
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nhắc nhở uống nước',
                style: TextStyle(
                  fontSize: AppFontSize.lg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              Switch(
                value: formState.waterReminderEnabled,
                onChanged: notifier.setWaterReminderEnabled,
                activeThumbColor: AppColors.white,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: AppColors.grey,
                inactiveTrackColor: AppColors.greyLight,
              ),
            ],
          ),
          if (formState.waterReminderEnabled) ...[
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Khoảng cách nhắc nhở (giờ)',
              style: TextStyle(color: AppColors.grey, fontSize: AppFontSize.sm),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [1, 2, 3, 4].map((hours) {
                final isSelected = formState.waterReminderInterval == hours;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text('$hours giờ'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) notifier.setWaterReminderInterval(hours);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.black,
                      fontSize: 12,
                    ),
                    backgroundColor: AppColors.white,
                    side: BorderSide(
                      color: isSelected
                          ? AppColors.primary
                          : AppColors.cardBorder,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: HealthFormFieldBuilder.buildTimeSelector(
                    context: context,
                    label: 'Giờ thức dậy',
                    currentTime: formState.wakeTime,
                    onChanged: notifier.setWakeTime,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: HealthFormFieldBuilder.buildTimeSelector(
                    context: context,
                    label: 'Giờ đi ngủ',
                    currentTime: formState.sleepTime,
                    onChanged: notifier.setSleepTime,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
