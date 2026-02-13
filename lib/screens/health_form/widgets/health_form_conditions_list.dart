import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';
import 'health_form_field_builder.dart';

class HealthFormConditionsList extends ConsumerWidget {
  final TextEditingController injuryController;
  final TextEditingController conditionController;

  const HealthFormConditionsList({
    super.key,
    required this.injuryController,
    required this.conditionController,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formState = ref.watch(healthFormProvider);
    final notifier = ref.read(healthFormProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        HealthFormFieldBuilder.buildListField(
          label: 'Chấn thương hiện tại',
          items: formState.injuries,
          controller: injuryController,
          placeholder: 'VD: Đau đầu gối trái, đau lưng dưới...',
          onAdd: () {
            if (injuryController.text.trim().isNotEmpty) {
              notifier.addInjury(injuryController.text.trim());
              injuryController.clear();
            }
          },
          onRemove: notifier.removeInjury,
        ),
        const SizedBox(height: AppSpacing.lg),
        HealthFormFieldBuilder.buildListField(
          label: 'Tình trạng sức khỏe',
          items: formState.medicalConditions,
          controller: conditionController,
          placeholder: 'VD: Hen suyễn, tiểu đường, huyết áp cao...',
          onAdd: () {
            if (conditionController.text.trim().isNotEmpty) {
              notifier.addCondition(conditionController.text.trim());
              conditionController.clear();
            }
          },
          onRemove: notifier.removeCondition,
        ),
      ],
    );
  }
}
