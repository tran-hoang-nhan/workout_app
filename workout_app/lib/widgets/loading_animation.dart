import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../constants/app_constants.dart';

/// A standardized loading widget for the app that provides a consistent, 
/// premium "staggered dots wave" animation.
class AppLoading extends StatelessWidget {
  /// Size of the loading animation.
  final double size;
  
  /// Custom color for the animation. Defaults to [AppColors.primary].
  final Color? color;
  
  /// Optional message to display below the animation.
  final String? message;

  /// Creates a standardized [AppLoading] widget.
  const AppLoading({
    super.key, 
    this.size = 40.0, 
    this.color, 
    this.message,
  });

  /// Factory method to provide a full-screen loading overlay.
  /// Used for major transitions (e.g., login checking status).
  static Widget fullScreen({String? message}) {
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.9),
      body: Center(
        child: AppLoading(
          size: 60,
          message: message,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeColor = color ?? AppColors.primary;
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        LoadingAnimationWidget.staggeredDotsWave(
          color: themeColor,
          size: size,
        ),
        if (message != null) ...[
          const SizedBox(height: AppSpacing.lg),
          Text(
            message!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: 15,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              decoration: TextDecoration.none, // For scaffold-less usage
            ),
          ),
        ],
      ],
    );
  }
}
