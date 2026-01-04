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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      child: Row(
        children: [
          if (currentStep > 1)
            Expanded(
              flex: 1,
              child: GestureDetector(
                onTap: onBack,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
                  ),
                  child: Center(
                    child: Text(
                      'Quay lại',
                      style: TextStyle(
                        color: AppColors.black.withValues(alpha: 0.7),
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          if (currentStep > 1) const SizedBox(width: AppSpacing.md),
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: isSaving ? null : onNext,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 18),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppColors.primary,
                      AppColors.primaryDark,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (isSaving)
                      const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          valueColor: AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    else ...[
                      Text(
                        currentStep < totalSteps ? 'Tiếp tục' : 'Bắt đầu ngay',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 16,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(
                        currentStep < totalSteps
                            ? Icons.arrow_forward_rounded
                            : Icons.auto_awesome_rounded,
                        color: Colors.white,
                        size: 20,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
