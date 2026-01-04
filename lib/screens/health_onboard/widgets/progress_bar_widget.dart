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
        horizontal: AppSpacing.lg + 8,
        vertical: AppSpacing.sm,
      ),
      child: Row(
        children: List.generate(
          totalSteps,
          (index) {
            final isActive = (index + 1) <= currentStep;
            
            return Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                height: 8,
                margin: EdgeInsets.only(right: index < totalSteps - 1 ? 10 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  boxShadow: [
                    if (isActive)
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                  gradient: isActive
                      ? LinearGradient(
                          colors: [
                            AppColors.primary,
                            AppColors.primaryDark,
                          ],
                        )
                      : null,
                  color: isActive ? null : AppColors.cardBorder.withValues(alpha: 0.3),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
