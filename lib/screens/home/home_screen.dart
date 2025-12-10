import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import 'widgets/stats_section.dart';
import 'widgets/plan_section.dart';
import 'widgets/quick_workout_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 120),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Xin chào! 👋',
            style: TextStyle(
              fontSize: AppFontSize.xxxl,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          const Text(
            'Sẵn sàng tập luyện hôm nay chưa?',
            style: TextStyle(
              fontSize: AppFontSize.md,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Stats Section
          const StatsSection(),
          const SizedBox(height: AppSpacing.xl),
          
          // Plan Section (includes next workout)
          const PlanSection(),
          const SizedBox(height: AppSpacing.xl),
          
          // Quick Workout Section
          const QuickWorkoutSection(),
        ],
      ),
    );
  }
}
