import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class ProgressBarWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;

  const ProgressBarWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.lg,
        vertical: AppSpacing.md,
      ),
      child: Row(
        children: List.generate(
          totalSteps,
          (index) => Expanded(
            child: Container(
              height: 6,
              margin: EdgeInsets.only(right: index < totalSteps - 1 ? 8 : 0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(3),
                gradient: (index + 1) <= currentStep
                    ? LinearGradient(
                        colors: [
                          Colors.orange.shade500,
                          Colors.red.shade500,
                        ],
                      )
                    : null,
                color: (index + 1) <= currentStep ? null : Colors.grey.shade800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
