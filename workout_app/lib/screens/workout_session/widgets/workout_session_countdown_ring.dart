import 'package:flutter/material.dart';
import 'package:workout_app/constants/app_constants.dart';

class WorkoutSessionCountdownRing extends StatelessWidget {
  final int remainingSeconds;
  final int totalSeconds;
  final String title;
  final Color color;
  final IconData icon;

  const WorkoutSessionCountdownRing({
    super.key,
    required this.remainingSeconds,
    required this.totalSeconds,
    required this.title,
    required this.color,
    required this.icon,
  });

  String _formatTime(int totalSeconds) {
    final clamped = totalSeconds < 0 ? 0 : totalSeconds;
    final m = (clamped ~/ 60).toString().padLeft(2, '0');
    final s = (clamped % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final total = totalSeconds <= 0 ? 1 : totalSeconds;
    final remaining = remainingSeconds < 0 ? 0 : remainingSeconds;
    final progress = (remaining / total).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.15), width: 1),
      ),
      child: Row(
        children: [
          SizedBox(
            height: 50, width: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 50, width: 50,
                  child: CircularProgressIndicator(
                    value: progress, strokeWidth: 5, backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color), strokeCap: StrokeCap.round,
                  ),
                ),
                Text('${remainingSeconds < 0 ? 0 : remainingSeconds}s', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color)),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.8)),
                const SizedBox(height: 1),
                Text('${_formatTime(remainingSeconds)} / ${_formatTime(totalSeconds)}', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.black.withValues(alpha: 0.8))),
              ],
            ),
          ),
          Icon(icon, color: color.withValues(alpha: 0.4), size: 20),
        ],
      ),
    );
  }
}
