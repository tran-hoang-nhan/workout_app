import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/workout_provider.dart';
import 'package:shared/shared.dart';
import '../../utils/app_error.dart';
import 'widgets/workout_search_bar.dart';
import 'widgets/workout_card.dart';
import '../../widgets/loading_animation.dart';

class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen> {
  String _selectedCategory = 'Tất cả';
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    AsyncValue<List<Workout>> workoutsAsync;

    if (_searchQuery.isNotEmpty) {
      workoutsAsync = ref.watch(searchWorkoutsProvider(_searchQuery));
    } else {
      workoutsAsync = ref.watch(workoutsByCategoryProvider(_selectedCategory));
    }

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Premium Header (Scrollable)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg, 32, AppSpacing.lg, AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Khám phá bài tập',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w900,
                        color: AppColors.black,
                        letterSpacing: -1.0,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    WorkoutSearchBar(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    _buildCategoryChips(),
                    const SizedBox(height: AppSpacing.sm),
                  ],
                ),
              ),
            ),
            workoutsAsync.when(
              data: (workouts) {
                if (workouts.isEmpty) {
                  return const SliverFillRemaining(
                    child: Center(
                        child: Text('Không tìm thấy bài tập nào',
                            style: TextStyle(color: AppColors.grey))),
                  );
                }
                return SliverPadding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    120,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.lg),
                        child: WorkoutCard(workout: workouts[index]),
                      );
                    }, childCount: workouts.length),
                  ),
                );
              },
              loading: () => const SliverFillRemaining(
                child: Center(child: AppLoading()),
              ),
              error: (e, stack) => SliverFillRemaining(
                child: Center(
                  child: Text(
                    e is AppError ? e.userMessage : 'Lỗi: $e',
                    style: const TextStyle(color: AppColors.danger),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = [
      'Tất cả',
      'Toàn thân',
      'Ngực',
      'Lưng',
      'Chân',
      'Tay',
      'Cardio',
      'HIIT',
    ];
    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        separatorBuilder: (context, index) =>
            const SizedBox(width: AppSpacing.sm),
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = _selectedCategory == category;
          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedCategory = category;
                _searchQuery = '';
                _searchController.clear();
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isSelected ? AppColors.primary : AppColors.white,
                borderRadius: BorderRadius.circular(AppBorderRadius.full),
                border: Border.all(
                  color: isSelected
                      ? AppColors.primary
                      : AppColors.cardBorder.withValues(alpha: 0.5),
                ),
                boxShadow: isSelected
                    ? [
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.25),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ]
                    : null,
              ),
              child: Text(
                category,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                  color: isSelected ? AppColors.white : AppColors.grey,
                  letterSpacing: 0.2,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
