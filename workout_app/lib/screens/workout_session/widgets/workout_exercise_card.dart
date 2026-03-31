import 'package:flutter/material.dart';
import 'package:workout_app/constants/app_constants.dart';
import 'package:shared/shared.dart';
import 'package:workout_app/screens/exercises/widgets/exercise_animation_widget.dart';
import 'package:workout_app/screens/workout_session/widgets/workout_session_countdown_ring.dart';

class WorkoutExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final WorkoutItem item;
  final bool started;
  final bool inRest;
  final bool isPaused;
  final ValueChanged<bool>? onPlayPauseToggle;
  final bool isTimeBased;
  final int remainingSeconds;
  final int exerciseTotalSeconds;
  final int restTotalSeconds;
  final bool isPreview;

  const WorkoutExerciseCard({
    super.key,
    required this.exercise,
    required this.item,
    required this.started,
    required this.inRest,
    this.isPaused = false,
    this.onPlayPauseToggle,
    required this.isTimeBased,
    required this.remainingSeconds,
    required this.exerciseTotalSeconds,
    required this.restTotalSeconds,
    this.isPreview = false,
  });

  @override
  Widget build(BuildContext context) {
    final hasDuration = (item.durationSeconds ?? 0) > 0;
    final hasReps = (item.reps ?? 0) > 0;
    final restChipSeconds = inRest ? restTotalSeconds : (item.restSeconds ?? 0);

    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.05),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
        border: Border.all(
          color: AppColors.cardBorder.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          if (inRest)
            Container(
              margin: const EdgeInsets.only(bottom: 4),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withValues(alpha: 0.2)),
              ),
              child: const Text(
                'TIẾP THEO',
                style: TextStyle(
                  color: Colors.orange,
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          Text(
            exercise.name,
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: AppFontSize.xl,
              fontWeight: FontWeight.w900,
              color: AppColors.black,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
          const SizedBox(height: 4),
          Builder(
            builder: (_) {
              final chips = <Widget>[];
              if (hasDuration) {
                chips.add(_buildSmallChip(Icons.timer_outlined, Colors.purple, '${item.durationSeconds}s'));
              } else if (hasReps) {
                chips.add(_buildSmallChip(Icons.repeat, Colors.green, '${item.reps} lần'));
              }
              if (restChipSeconds > 0) {
                chips.add(_buildSmallChip(Icons.pause_circle_outline, Colors.red, 'Nghỉ ${restChipSeconds}s'));
              }
              return Wrap(
                alignment: WrapAlignment.center,
                spacing: 8,
                children: chips,
              );
            },
          ),
          const SizedBox(height: 8),
          if (exercise.animationUrl != null && exercise.animationUrl!.isNotEmpty)
            Expanded(
              flex: 8, 
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                  color: AppColors.white.withValues(alpha: 0.3),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                  child: ExerciseAnimationWidget(
                    animationUrl: exercise.animationUrl!,
                    height: double.infinity,
                    externalIsPlaying: !isPaused,
                    onPlayPauseToggle: onPlayPauseToggle,
                    showControls: false,
                  ),
                ),
              ),
            ),
          const SizedBox(height: 8),
          if (started)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: (!inRest && !isTimeBased)
                  ? WorkoutSessionRepsRing(
                      reps: item.reps ?? 0,
                      title: 'Đang tập',
                      color: AppColors.primary,
                      icon: Icons.repeat,
                    )
                  : WorkoutSessionCountdownRing(
                      remainingSeconds: remainingSeconds,
                      totalSeconds: inRest ? restTotalSeconds : exerciseTotalSeconds,
                      title: inRest ? 'Đang nghỉ' : 'Đang tập',
                      color: inRest ? AppColors.info : AppColors.primary,
                      icon: inRest ? Icons.pause_circle_filled : Icons.bolt_rounded,
                    ),
            )
          else if (isPreview) 
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: WorkoutNextPreviewBanner(),
            ),
          if (exercise.description != null && exercise.description!.isNotEmpty) ...[
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.black.withValues(alpha: 0.03),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                exercise.description!,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: AppColors.black.withValues(alpha: 0.5),
                  fontSize: 12,
                  height: 1.3,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSmallChip(IconData icon, Color color, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }
}

class WorkoutSessionRepsRing extends StatelessWidget {
  final int reps;
  final String title;
  final Color color;
  final IconData icon;

  const WorkoutSessionRepsRing({super.key, required this.reps, required this.title, required this.color, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: color.withValues(alpha: 0.15)),
      ),
      child: Row(
        children: [
          Container(
            height: 40, width: 40,
            decoration: BoxDecoration(color: color.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(10)),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(title.toUpperCase(), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: color, letterSpacing: 0.8)),
                const SizedBox(height: 1),
                Text('$reps lần', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class WorkoutNextPreviewBanner extends StatelessWidget {
  const WorkoutNextPreviewBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 14),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
        border: Border.all(color: Colors.orange.withValues(alpha: 0.15)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: Colors.orange, shape: BoxShape.circle), child: const Icon(Icons.visibility_rounded, color: Colors.white, size: 12)),
              const SizedBox(width: 8),
              const Text('XEM TRƯỚC BÀI TIẾP THEO', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: Colors.orange, letterSpacing: 1.0)),
            ],
          ),
          const SizedBox(height: 4),
          Text('Chuẩn bị sẵn sàng cho bài tập kế tiếp', style: TextStyle(fontSize: 12, color: Colors.orange.withValues(alpha: 0.7), fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
