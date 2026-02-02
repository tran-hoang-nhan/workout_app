import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class AchievementsSection extends StatelessWidget {
  final int totalWorkouts;
  
  const AchievementsSection({
    super.key,
    required this.totalWorkouts,
  });

  @override
  Widget build(BuildContext context) {
    // Simple level calculation: 5 workouts per level
    final level = (totalWorkouts / 5).floor() + 1;
    final progressInLevel = (totalWorkouts % 5) / 5;

    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Hành trình của bạn',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            // Level Card
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF6366F1), Color(0xFFA855F7)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                    blurRadius: 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.workspace_premium, color: Colors.white, size: 30),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Cấp độ $level',
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.w900,
                                color: Colors.white,
                              ),
                            ),
                            Text(
                              'Bạn đã hoàn thành $totalWorkouts bài tập',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.white.withValues(alpha: 0.8),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progressInLevel,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Tiến độ cấp tiếp theo',
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.white.withValues(alpha: 0.7),
                        ),
                      ),
                      Text(
                        '${(progressInLevel * 100).toInt()}%',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            // Badges Row
            const Text(
              'Huy hiệu đạt được',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            SizedBox(
              height: 100,
              child: ListView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildBadge('Người mới', Icons.star, Colors.amber, totalWorkouts >= 1),
                  _buildBadge('Kiên trì', Icons.bolt, Colors.orange, totalWorkouts >= 5),
                  _buildBadge('Kỷ luật', Icons.shield, Colors.blue, totalWorkouts >= 10),
                  _buildBadge('Vô địch', Icons.emoji_events, Colors.purple, totalWorkouts >= 20),
                  _buildBadge('Huyền thoại', Icons.local_fire_department, Colors.red, totalWorkouts >= 50),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBadge(String name, IconData icon, Color color, bool unlocked) {
    return Container(
      width: 80,
      margin: const EdgeInsets.only(right: AppSpacing.md),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: unlocked ? color.withValues(alpha: 0.1) : Colors.grey.shade100,
              shape: BoxShape.circle,
              border: unlocked ? Border.all(color: color.withValues(alpha: 0.3), width: 2) : null,
            ),
            child: Icon(
              icon, 
              color: unlocked ? color : Colors.grey.shade400, 
              size: 24
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: TextStyle(
              fontSize: 10,
              fontWeight: unlocked ? FontWeight.bold : FontWeight.normal,
              color: unlocked ? AppColors.black : Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
