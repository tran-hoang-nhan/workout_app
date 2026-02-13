import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';
import 'health_form_field_builder.dart';

class HealthFormBasicStats extends ConsumerWidget {
  const HealthFormBasicStats({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(healthFormProvider);
    final notifier = ref.read(healthFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HealthFormFieldBuilder.buildInputField(
          label: 'Tuổi',
          value: formState.age.toString(),
          onChanged: (value) =>
              notifier.setAge(int.tryParse(value) ?? formState.age),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.lg),
        HealthFormFieldBuilder.buildInputField(
          label: 'Cân nặng (kg)',
          value: formState.weight.toString(),
          onChanged: (value) =>
              notifier.setWeight(double.tryParse(value) ?? formState.weight),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.lg),
        HealthFormFieldBuilder.buildInputField(
          label: 'Chiều cao (cm)',
          value: formState.height.toString(),
          onChanged: (value) =>
              notifier.setHeight(double.tryParse(value) ?? formState.height),
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.lg),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Giới tính',
              style: TextStyle(
                fontSize: AppFontSize.lg,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                border: Border.all(color: AppColors.cardBorder),
                borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: formState.gender,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: AppColors.grey,
                    ),
                    items: const [
                      DropdownMenuItem(
                        value: 'male',
                        child: Text(
                          'Nam',
                          style: TextStyle(color: AppColors.black),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'female',
                        child: Text(
                          'Nữ',
                          style: TextStyle(color: AppColors.black),
                        ),
                      ),
                      DropdownMenuItem(
                        value: 'other',
                        child: Text(
                          'Khác',
                          style: TextStyle(color: AppColors.black),
                        ),
                      ),
                    ],
                    onChanged: (value) {
                      if (value != null) notifier.setGender(value);
                    },
                    dropdownColor: AppColors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
