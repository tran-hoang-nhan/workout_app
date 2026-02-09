import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';
import 'health_form_field_builder.dart';

class HealthFormDietNutrition extends ConsumerWidget {
  final TextEditingController allergyController;

  const HealthFormDietNutrition({super.key, required this.allergyController});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(healthFormProvider);
    final notifier = ref.read(healthFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
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
                'Chế độ ăn uống',
                style: TextStyle(
                  fontSize: AppFontSize.lg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.cardBorder),
                  borderRadius: BorderRadius.circular(AppBorderRadius.md),
                ),
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: formState.dietType,
                    onChanged: (value) =>
                        notifier.setDietType(value ?? 'normal'),
                    items:
                        [
                              ('normal', 'Bình thường'),
                              ('vegan', 'Thuần chay (Vegan)'),
                              ('vegetarian', 'Chay (Vegetarian)'),
                              ('keto', 'Keto'),
                              ('paleo', 'Paleo'),
                              ('low_carb', 'Low Carb'),
                              ('halal', 'Halal'),
                            ]
                            .map(
                              (item) => DropdownMenuItem(
                                value: item.$1,
                                child: Text(
                                  item.$2,
                                  style: const TextStyle(
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                    style: const TextStyle(color: AppColors.black),
                    icon: const Icon(
                      Icons.arrow_drop_down,
                      color: AppColors.grey,
                    ),
                    dropdownColor: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        HealthFormFieldBuilder.buildListField(
          label: 'Dị ứng thực phẩm',
          items: formState.allergies,
          controller: allergyController,
          placeholder: 'VD: Đậu phộng, hải sản, sữa...',
          onAdd: () {
            if (allergyController.text.trim().isNotEmpty) {
              notifier.addAllergy(allergyController.text.trim());
              allergyController.clear();
            }
          },
          onRemove: notifier.removeAllergy,
        ),
      ],
    );
  }
}
