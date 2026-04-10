import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class AuthLogoSection extends StatelessWidget {
  final String title;
  final String subtitle;

  const AuthLogoSection({
    super.key,
    this.title = 'Workout App',
    this.subtitle = 'Bắt đầu hành trình fitness của bạn',
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.grey,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }
}
