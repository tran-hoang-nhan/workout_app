import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_constants.dart';
import '../../../utils/app_error.dart';
import '../../../widgets/loading_animation.dart';
import '../../../models/workout_history.dart';

class WorkoutHistoryList extends StatelessWidget {
  final AsyncValue<List<dynamic>> historyAsync;

  const WorkoutHistoryList({super.key, required this.historyAsync});

  @override
  Widget build(BuildContext context) {
    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) {
          return const SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xl),
                child: Text('Chưa có lịch sử tập luyện'),
              ),
            ),
          );
        }
        return SliverList(
          delegate: SliverChildBuilderDelegate((context, index) {
            final item = history[index];
            final workoutName = item is WorkoutHistory
                ? item.workoutName
                : (item as dynamic).workoutName;
            final completedAt = item is WorkoutHistory
                ? item.completedAt
                : (item as dynamic).completedAt;
            final calories = item is WorkoutHistory
                ? item.totalCaloriesCalo
                : (item as dynamic).totalCaloriesCalo;
            final duration = item is WorkoutHistory
                ? item.durationSeconds
                : (item as dynamic).durationSeconds;

            return Container(
              margin: const EdgeInsets.symmetric(
                horizontal: AppSpacing.lg,
                vertical: AppSpacing.xs,
              ),
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.fitness_center,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workoutName ?? 'Bài tập',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          DateFormat(
                            'dd/MM/yyyy • HH:mm',
                          ).format(completedAt ?? DateTime.now()),
                          style: TextStyle(fontSize: 12, color: AppColors.grey),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        '${calories?.toInt() ?? 0} calo',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                      ),
                      Text(
                        '${(duration ?? 0) ~/ 60}p',
                        style: TextStyle(fontSize: 12, color: AppColors.grey),
                      ),
                    ],
                  ),
                ],
              ),
            );
          }, childCount: history.length),
        );
      },
      loading: () => const SliverToBoxAdapter(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(AppSpacing.xl),
            child: AppLoading(size: 40),
          ),
        ),
      ),
      error: (e, _) => SliverToBoxAdapter(
        child: Center(
          child: Text(
            e is AppError ? e.userMessage : 'Lỗi: $e',
            style: const TextStyle(color: Colors.red),
          ),
        ),
      ),
    );
  }
}
