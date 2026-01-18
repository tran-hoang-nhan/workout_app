import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../models/exercise.dart';
import '../../../models/workout_item.dart';
import '../../exercises/widgets/exercise_animation_widget.dart';
import 'workout_session_countdown_ring.dart';
import 'workout_session_info_chip.dart';

class WorkoutExerciseCard extends StatelessWidget {
  final Exercise exercise;
  final WorkoutItem item;
  final bool started;
  final bool inRest;
  final bool isTimeBased;
  final int remainingSeconds;

  const WorkoutExerciseCard({
    super.key,
    required this.exercise,
    required this.item,
    required this.started,
    required this.inRest,
    required this.isTimeBased,
    required this.remainingSeconds,
  });

  @override
  Widget build(BuildContext context) {
    final hasDuration = (item.durationSeconds ?? 0) > 0;
    final hasReps = (item.reps ?? 0) > 0;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x14000000),
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    exercise.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (exercise.animationUrl != null &&
                      exercise.animationUrl!.isNotEmpty)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: ExerciseAnimationWidget(
                          animationUrl: exercise.animationUrl!,
                          height: 240,
                        ),
                      ),
                    )
                  else if (exercise.thumbnailUrl != null &&
                      exercise.thumbnailUrl!.isNotEmpty)
                    Center(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: CachedNetworkImage(
                          imageUrl: exercise.thumbnailUrl!,
                          height: 240,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            height: 240,
                            color: Colors.grey[200],
                            child: const Center(
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            height: 240,
                            color: Colors.grey[200],
                            child: const Icon(
                              Icons.image_not_supported,
                              size: 40,
                            ),
                          ),
                        ),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Center(
                    child: Builder(
                      builder: (_) {
                        final chips = <Widget>[];
                        if (hasDuration) {
                          chips.add(
                            WorkoutSessionInfoChip(
                              icon: Icons.timer_outlined,
                              color: Colors.purple,
                              text: 'Tập: ${item.durationSeconds} giây',
                            ),
                          );
                        } else if (hasReps) {
                          chips.add(
                            WorkoutSessionInfoChip(
                              icon: Icons.repeat,
                              color: Colors.green,
                              text: 'Số lần: ${item.reps}',
                            ),
                          );
                        } else {
                          chips.add(
                            const WorkoutSessionInfoChip(
                              icon: Icons.fitness_center,
                              color: Colors.blueGrey,
                              text: 'Tập tự do',
                            ),
                          );
                        }
                        if ((item.restSeconds ?? 0) > 0) {
                          chips.add(
                            WorkoutSessionInfoChip(
                              icon: Icons.pause_circle_outline,
                              color: Colors.red,
                              text: 'Nghỉ: ${item.restSeconds} giây',
                            ),
                          );
                        }
                        return Wrap(
                          alignment: WrapAlignment.center,
                          spacing: 12,
                          runSpacing: 8,
                          children: chips,
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (exercise.description != null)
                    Text(
                      exercise.description!,
                      style: TextStyle(color: Colors.grey[700]),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (started)
            Builder(
              builder: (_) {
                if (inRest) {
                  return WorkoutSessionCountdownRing(
                    remainingSeconds: remainingSeconds,
                    totalSeconds: item.restSeconds ?? 0,
                    title: 'Nghỉ',
                    color: AppColors.info,
                    icon: Icons.pause_circle_filled,
                  );
                }
                if (isTimeBased) {
                  return WorkoutSessionCountdownRing(
                    remainingSeconds: remainingSeconds,
                    totalSeconds: item.durationSeconds ?? 0,
                    title: 'Đang tập',
                    color: AppColors.primary,
                    icon: Icons.bolt_rounded,
                  );
                }
                if (hasReps) {
                  return Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Colors.green.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          height: 44,
                          width: 44,
                          decoration: BoxDecoration(
                            color: Colors.green.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.repeat,
                            color: Colors.green,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Tập theo số lần',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${item.reps} lần',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w900,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blueGrey.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: Colors.blueGrey.withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      Container(
                        height: 44,
                        width: 44,
                        decoration: BoxDecoration(
                          color: Colors.blueGrey.withValues(alpha: 0.18),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.fitness_center,
                          color: Colors.blueGrey,
                          size: 22,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Tập tự do',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Center(
              child: Builder(
                builder: (_) {
                  String text;
                  if (hasDuration) {
                    text =
                        'Tập ${item.durationSeconds} giây${(item.restSeconds ?? 0) > 0 ? ' • Nghỉ ${item.restSeconds} giây' : ''}';
                  } else if (hasReps) {
                    text =
                        'Số lần ${item.reps}${(item.restSeconds ?? 0) > 0 ? ' • Nghỉ ${item.restSeconds} giây' : ''}';
                  } else {
                    text =
                        'Tập tự do${(item.restSeconds ?? 0) > 0 ? ' • Nghỉ ${item.restSeconds} giây' : ''}';
                  }
                  return Text(
                    text,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
