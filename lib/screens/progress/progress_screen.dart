import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/progress_provider.dart';
import '../../providers/progress_user_provider.dart';
import 'widgets/history_list.dart';
import 'widgets/progress_header.dart';
import 'widgets/achievements_section.dart';
import 'widgets/weekly_activity_slider.dart';
import 'widgets/running_card.dart';

class ProgressScreen extends ConsumerStatefulWidget {
  const ProgressScreen({super.key});

  @override
  ConsumerState<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends ConsumerState<ProgressScreen> {
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDay = DateTime(now.year, now.month, now.day);
  }

  @override
  Widget build(BuildContext context) {
    final historyAsync = ref.watch(workoutHistoryProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            const ProgressHeader(),
            WeeklyActivitySlider(
              selectedDay: _selectedDay,
              onDaySelected: (day) {
                setState(() {
                  _selectedDay = day;
                });
              },
            ),
            const RunningCard(),
            
            // Replaced Statistics with Achievements
            historyAsync.when(
              data: (history) => AchievementsSection(totalWorkouts: history.length),
              loading: () => const SliverToBoxAdapter(
                child: Center(child: CircularProgressIndicator()),
              ),
              error: (e, _) => SliverToBoxAdapter(
                child: Center(child: Text('Lỗi tải thành tích: $e')),
              ),
            ),

            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
                child: Text(
                  'Hoạt động gần đây',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
              ),
            ),
            WorkoutHistoryList(historyAsync: historyAsync),
            const SliverToBoxAdapter(child: SizedBox(height: 120)),
          ],
        ),
      ),
    );
  }
}
