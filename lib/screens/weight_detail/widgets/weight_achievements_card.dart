import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/weight_provider.dart';
import '../../../models/body_metric.dart';

class WeightAchievementsCard extends ConsumerWidget {
  const WeightAchievementsCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(weightHistoryProvider);

    return historyAsync.when(
      data: (history) {
        if (history.isEmpty) return const SizedBox.shrink();

        final streak = _calculateStreak(history);
        final milestones = _calculateMilestones(history);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'THÀNH TÍCH & ĐỘNG LỰC',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.black,
                letterSpacing: 1,
              ),
            ),
            const SizedBox(height: 16),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              child: Row(
                children: [
                  _buildStreakCard(streak),
                  if (milestones.isNotEmpty) ...milestones.map((m) => Padding(
                    padding: const EdgeInsets.only(left: AppSpacing.md),
                    child: _buildMilestoneCard(m.title, m.subtitle, m.icon, m.color),
                  )),
                ],
              ),
            ),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, _) => const SizedBox.shrink(),
    );
  }

  int _calculateStreak(List<BodyMetric> history) {
    if (history.isEmpty) return 0;
    
    final sorted = history.toList()..sort((a, b) => b.recordedAt.compareTo(a.recordedAt));
    
    int streak = 0;
    DateTime lastDate = DateTime.now();
    
    final firstDiff = DateTime(lastDate.year, lastDate.month, lastDate.day)
        .difference(DateTime(sorted[0].recordedAt.year, sorted[0].recordedAt.month, sorted[0].recordedAt.day))
        .inDays;
        
    if (firstDiff > 1) return 0;

    DateTime currentStreakDate = DateTime(sorted[0].recordedAt.year, sorted[0].recordedAt.month, sorted[0].recordedAt.day);
    streak = 1;

    for (int i = 1; i < sorted.length; i++) {
      final itemDate = DateTime(sorted[i].recordedAt.year, sorted[i].recordedAt.month, sorted[i].recordedAt.day);
      final diff = currentStreakDate.difference(itemDate).inDays;
      
      if (diff == 1) {
        streak++;
        currentStreakDate = itemDate;
      } else if (diff == 0) {
        continue;
      } else {
        break;
      }
    }

    return streak;
  }

  List<_MilestoneData> _calculateMilestones(List<BodyMetric> history) {
    final List<_MilestoneData> milestones = [];
    if (history.length < 2) return [];

    final sorted = history.toList()..sort((a, b) => a.recordedAt.compareTo(b.recordedAt));
    final initialWeight = sorted.first.weight;
    final currentWeight = sorted.last.weight;
    final weightDiff = initialWeight - currentWeight;

    if (weightDiff >= 5) {
      milestones.add(_MilestoneData(
        title: 'Giảm ${weightDiff.toStringAsFixed(1)}kg',
        subtitle: 'Thành tích tuyệt vời!',
        icon: Icons.emoji_events_rounded,
        color: Colors.orange,
      ));
    } else if (weightDiff > 0) {
       milestones.add(_MilestoneData(
        title: 'Đang tiến bộ',
        subtitle: 'Đã giảm ${weightDiff.toStringAsFixed(1)}kg',
        icon: Icons.trending_down_rounded,
        color: Colors.green,
      ));
    }

    milestones.add(_MilestoneData(
      title: 'Kiên trì',
      subtitle: 'Đã cập nhật ${history.length} lần',
      icon: Icons.verified_rounded,
      color: Colors.blue,
    ));

    return milestones;
  }

  Widget _buildStreakCard(int streak) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFFF7F00), Color(0xFFFFBF00)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF7F00).withValues(alpha: 0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(Icons.star_rounded, color: Colors.white, size: 32),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$streak NGÀY',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: Colors.white,
                ),
              ),
              const Text(
                'Chuỗi cập nhật',
                style: TextStyle(
                  fontSize: 10,
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMilestoneCard(String title, String subtitle, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: color.darken(0.2),
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(
                  fontSize: 10,
                  color: color.darken(0.1),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _MilestoneData {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  _MilestoneData({required this.title, required this.subtitle, required this.icon, required this.color});
}

extension ColorExtension on Color {
  Color darken([double amount = .1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }
}
