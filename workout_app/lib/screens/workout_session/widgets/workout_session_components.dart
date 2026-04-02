import 'package:flutter/material.dart';
import 'package:workout_app/constants/app_constants.dart';

class WorkoutSessionInfoChip extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color? color;

  const WorkoutSessionInfoChip({
    super.key,
    required this.icon,
    required this.text,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 8,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color ?? Colors.black54),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class WorkoutSessionStatChip extends StatelessWidget {
  final String label;
  final String value;

  const WorkoutSessionStatChip({super.key, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey[600], fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}

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
            height: 50,
            width: 50,
            child: Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  height: 50,
                  width: 50,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 5,
                    backgroundColor: color.withValues(alpha: 0.12),
                    valueColor: AlwaysStoppedAnimation<Color>(color),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Text(
                  '${remainingSeconds < 0 ? 0 : remainingSeconds}s',
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: color),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: color,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  '${_formatTime(remainingSeconds)} / ${_formatTime(totalSeconds)}',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.black.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ),
          Icon(icon, color: color.withValues(alpha: 0.4), size: 20),
        ],
      ),
    );
  }
}
