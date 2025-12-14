import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class NavigationButtonsWidget extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final bool isSaving;
  final VoidCallback onBack;
  final VoidCallback onNext;

  const NavigationButtonsWidget({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.isSaving,
    required this.onBack,
    required this.onNext,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (currentStep > 1)
          Expanded(
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: AppSpacing.md,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  border: Border.all(color: Colors.grey.shade800),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.arrow_back, color: Colors.grey),
                    SizedBox(width: 8),
                    Text(
                      'Quay lại',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        if (currentStep > 1) const SizedBox(width: AppSpacing.md),
        Expanded(
          child: GestureDetector(
            onTap: isSaving ? null : onNext,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.orange.shade500,
                    Colors.red.shade500,
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (isSaving)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    )
                  else
                    Text(
                      currentStep < totalSteps ? 'Tiếp tục' : 'Hoàn thành',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(width: 8),
                  Icon(
                    currentStep < totalSteps
                        ? Icons.arrow_forward
                        : Icons.check_circle,
                    color: Colors.white,
                    size: 20,
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
