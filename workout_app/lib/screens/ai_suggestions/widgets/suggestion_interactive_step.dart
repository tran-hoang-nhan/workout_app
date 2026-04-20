import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../../../widgets/loading_animation.dart';
import 'health_edit_form.dart';
import 'health_validation_card.dart';
import '../../../providers/ai_suggestion_provider.dart';


class SuggestionInteractiveStep extends StatelessWidget {
  final AISuggestionStep currentStep;
  final HealthUpdateParams healthState;
  final VoidCallback onConfirm;
  final VoidCallback onEdit;
  final Function(HealthUpdateParams) onSaveEdit;
  final VoidCallback onCancelEdit;

  const SuggestionInteractiveStep({
    super.key,
    required this.currentStep,
    required this.healthState,
    required this.onConfirm,
    required this.onEdit,
    required this.onSaveEdit,
    required this.onCancelEdit,
  });

  @override
  Widget build(BuildContext context) {
    switch (currentStep) {
      case AISuggestionStep.validating:
        return HealthValidationCard(
          healthData: healthState,
          onConfirm: onConfirm,
          onEdit: onEdit,
        );
      case AISuggestionStep.editing:
        return HealthEditForm(
          initialState: healthState,
          onSave: onSaveEdit,
          onCancel: onCancelEdit,
        );
      case AISuggestionStep.askingRequirement:
        return const SizedBox.shrink();
      case AISuggestionStep.generating:
        return const Padding(
          padding: EdgeInsets.symmetric(vertical: 20),
          child: AppLoading(
            message: 'AI đang phân tích dữ liệu của bạn...',
          ),
        );
      case AISuggestionStep.results:
        return const SizedBox.shrink();
    }
  }
}
