import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/workout_provider.dart';
import '../../models/workout.dart';

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
    } else if (_selectedCategory != 'Tất cả') {
      workoutsAsync = ref.watch(workoutsByCategoryProvider(_selectedCategory));
    } else {
      workoutsAsync = ref.watch(workoutsProvider);
    }

    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bài tập',
                    style: TextStyle(
                      fontSize: AppFontSize.xxxl,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSearchBar(),
                  const SizedBox(height: AppSpacing.lg),
                  _buildCategoryChips(),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
            Expanded(
              child: workoutsAsync.when(
                data: (workouts) {
                  if (workouts.isEmpty) {
                    return const Center(
                      child: Text('Không tìm thấy bài tập nào'),
                    );
                  }
                  return ListView.separated(
                    padding: const EdgeInsets.fromLTRB(AppSpacing.lg, 0, AppSpacing.lg, 120),
                    itemCount: workouts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.lg),
                    itemBuilder: (context, index) {
                      final workout = workouts[index];
                      return _buildWorkoutCard(workout);
                    },
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, stack) => Center(child: Text('Lỗi: $err')),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: TextField(
          controller: _searchController,
          onChanged: (value) {
            setState(() {
              _searchQuery = value;
            });
          },
          decoration: const InputDecoration(
            hintText: 'Tìm kiếm bài tập...',
            hintStyle: TextStyle(color: Color(0xFF999999)),
            prefixIcon: Icon(Icons.search, color: Color(0xFF999999)),
            border: InputBorder.none,
            contentPadding: EdgeInsets.symmetric(vertical: AppSpacing.md),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = ['Tất cả', 'Cardio', 'Sức mạnh', 'Yoga', 'HIIT'];
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          categories.length,
          (index) {
            final category = categories[index];
            final isSelected = _selectedCategory == category;
            return Padding(
              padding: EdgeInsets.only(right: index < categories.length - 1 ? AppSpacing.md : 0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedCategory = category;
                    _searchQuery = '';
                    _searchController.clear();
                  });
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [Color(0xFFFF7F00), Color(0xFFFF0000)],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isSelected ? null : const Color.fromARGB(255, 247, 248, 250),
                    border: Border.all(
                      color: isSelected ? Colors.transparent : const Color.fromARGB(255, 207, 209, 211),
                    ),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: Text(
                    category,
                    style: TextStyle(
                      fontSize: AppFontSize.sm,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? AppColors.white : AppColors.grey,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(Workout workout) {
    // Map level to Vietnamese and UI colors
    String levelText = 'Dễ';
    List<Color> gradientColors = [const Color(0xFFA855F7), const Color(0xFFEC4899)];
    IconData icon = Icons.fitness_center;

    switch (workout.level?.toLowerCase()) {
      case 'beginner':
      case 'dễ':
        levelText = 'Dễ';
        gradientColors = [const Color(0xFFA855F7), const Color(0xFFEC4899)];
        icon = Icons.self_improvement;
        break;
      case 'intermediate':
      case 'trung bình':
        levelText = 'Trung bình';
        gradientColors = [const Color(0xFF3B82F6), const Color(0xFF06B6D4)];
        icon = Icons.favorite;
        break;
      case 'advanced':
      case 'nâng cao':
        levelText = 'Nâng cao';
        gradientColors = [const Color(0xFFEF4444), const Color(0xFFEC4899)];
        icon = Icons.flash_on;
        break;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 350;
        
        return Container(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
            border: Border.all(color: const Color.fromARGB(255, 241, 241, 241)),
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          workout.title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 6),
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            children: [
                              Text(
                                '${workout.estimatedDuration ?? 0} phút',
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF999999),
                                ),
                              ),
                              const Text(
                                ' • ',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF999999),
                                ),
                              ),
                              Text(
                                levelText,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF999999),
                                ),
                              ),
                              if (workout.isPremium) ...[
                                const Text(
                                  ' • ',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFF999999),
                                  ),
                                ),
                                const Text(
                                  'Premium',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Color(0xFFFF7F00),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    width: isSmallScreen ? 56 : 64,
                    height: isSmallScreen ? 56 : 64,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: gradientColors,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    ),
                    child: Icon(
                      icon,
                      color: AppColors.white,
                      size: isSmallScreen ? 26 : 30,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromARGB(255, 237, 81, 9),
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 8 : 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    ),
                  ),
                  onPressed: () {
                    // Navigate to detail
                  },
                  child: Text(
                    'Bắt đầu',
                    style: TextStyle(
                      fontSize: isSmallScreen ? 12 : 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

