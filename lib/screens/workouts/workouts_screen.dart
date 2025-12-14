import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';

class WorkoutsScreen extends ConsumerWidget {
  const WorkoutsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 120),
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
              const SizedBox(height: AppSpacing.xl),
              _buildWorkoutCard(
                'Tập Ngực & Tay',
                '40 phút',
                '380 kcal',
                'Nâng cao',
                Icons.fitness_center,
                [const Color(0xFF3B82F6), const Color(0xFF06B6D4)],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildWorkoutCard(
                'Cardio Giảm Cân',
                '30 phút',
                '420 kcal',
                'Trung bình',
                Icons.favorite,
                [const Color(0xFFEF4444), const Color(0xFFEC4899)],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildWorkoutCard(
                'HIIT Cường Độ Cao',
                '25 phút',
                '500 kcal',
                'Nâng cao',
                Icons.flash_on,
                [const Color(0xFFEAB308), const Color(0xFFEA580C)],
              ),
              const SizedBox(height: AppSpacing.lg),
              _buildWorkoutCard(
                'Yoga Buổi Tối',
                '35 phút',
                '180 kcal',
                'Dễ',
                Icons.self_improvement,
                [const Color(0xFFA855F7), const Color(0xFFEC4899)],
              ),
            ],
          ),
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
      child: const Padding(
        padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
        child: TextField(
          decoration: InputDecoration(
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
          (index) => Padding(
            padding: EdgeInsets.only(right: index < categories.length - 1 ? AppSpacing.md : 0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
              decoration: BoxDecoration(
                gradient: index == 0
                    ? const LinearGradient(
                        colors: [Color(0xFFFF7F00), Color(0xFFFF0000)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : null,
                color: index == 0 ? null : const Color(0xFF0A1A3F),
                border: Border.all(
                  color: index == 0 ? Colors.transparent : const Color(0xFF1A3A5F),
                ),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Text(
                categories[index],
                style: TextStyle(
                  fontSize: AppFontSize.sm,
                  fontWeight: FontWeight.w600,
                  color: index == 0 ? AppColors.white : AppColors.grey,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(
    String title,
    String duration,
    String calories,
    String level,
    IconData icon,
    List<Color> gradientColors,
  ) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final isSmallScreen = screenWidth < 350;
        
        return Container(
          padding: EdgeInsets.all(isSmallScreen ? 10 : 12),
          decoration: BoxDecoration(
            color: const Color(0xFF0A1A3F),
            borderRadius: BorderRadius.circular(AppBorderRadius.xl),
            border: Border.all(color: const Color(0xFF1A3A5F)),
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
                          title,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.white,
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
                                duration,
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
                                calories,
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
                                level,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Color(0xFF999999),
                                ),
                              ),
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
                    backgroundColor: const Color(0xFF1A1A1A),
                    padding: EdgeInsets.symmetric(
                      vertical: isSmallScreen ? 8 : 10,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    ),
                  ),
                  onPressed: () {},
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
