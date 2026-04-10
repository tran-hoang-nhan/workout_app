import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../../../constants/app_constants.dart';

class AuthSubmitButton extends StatelessWidget {
  final String text;
  final bool isLoading;
  final VoidCallback? onTap;

  const AuthSubmitButton({
    super.key,
    required this.text,
    this.isLoading = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: isLoading ? null : onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isLoading
                ? [Colors.grey.shade600, Colors.grey.shade700]
                : [Colors.orange.shade500, Colors.red.shade500],
          ),
          boxShadow: [
            BoxShadow(
              color: (onTap == null || isLoading)
                  ? Colors.transparent
                  : Colors.orange.shade500.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: isLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: LoadingAnimationWidget.staggeredDotsWave(
                    color: Colors.white,
                    size: 20,
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      text,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
