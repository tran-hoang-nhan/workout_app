import 'package:flutter/material.dart';
import 'workout_session_stat_chip.dart';

String _formatDuration(int seconds) {
  final clamped = seconds < 0 ? 0 : seconds;
  final h = clamped ~/ 3600;
  final m = (clamped % 3600) ~/ 60;
  final s = clamped % 60;
  if (h > 0) {
    return '${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

Future<void> showWorkoutCompletionDialog(
  BuildContext context, {
  required String workoutTitle,
  required int totalItems,
  required int totalSeconds,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.green.withValues(alpha: 0.1),
                Colors.blue.withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.green.withValues(alpha: 0.15),
                ),
                child: const Icon(
                  Icons.check_rounded,
                  color: Colors.green,
                  size: 48,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Hoàn thành set!',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Text(
                workoutTitle,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey[700], fontSize: 14),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  WorkoutSessionStatChip(label: 'Bài', value: '$totalItems'),
                  WorkoutSessionStatChip(
                    label: 'Thời gian',
                    value: _formatDuration(totalSeconds),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.of(ctx).pop();
                    Navigator.of(context).pop();
                  },
                  child: const Text('Về trang trước'),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
