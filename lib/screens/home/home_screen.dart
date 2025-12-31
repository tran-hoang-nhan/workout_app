import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import 'widgets/stats_section.dart';
import 'widgets/plan_section.dart';
import 'widgets/quick_workout_section.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 90),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with Profile & Notifications
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                   Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.primary.withValues(alpha: 0.2), width: 2),
                      image: const DecorationImage(
                        image: NetworkImage('https://i.pravatar.cc/150?u=workout_user'),
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Chào mừng trở lại! 👋',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Hoàng Nhân',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Badge(
                  label: Text('2'),
                  child: Icon(Icons.notifications_outlined, color: AppColors.black, size: 24),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          
          // Stats Section
          const StatsSection(),
          const SizedBox(height: AppSpacing.md),
          
          // Plan Section (includes next workout)
          const PlanSection(),
          const SizedBox(height: AppSpacing.lg),
          
          // Quick Workout Section
          const QuickWorkoutSection(),
        ],
      ),
    );
  }
}
