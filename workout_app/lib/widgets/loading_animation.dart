import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import '../constants/app_constants.dart';

class AppLoading extends StatelessWidget {
  final double size;
  final Color? color;
  final String? message;

  const AppLoading({super.key, this.size = 50.0, this.color, this.message});

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
    final activeColor = color ?? AppColors.primary;
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        LoadingAnimationWidget.staggeredDotsWave(
          color: activeColor,
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
            ),
          ),
        ],
      ],
    );
  }
}
