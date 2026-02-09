import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../models/workout.dart';
import '../../../utils/label_utils.dart';

class WorkoutHeader extends StatelessWidget {
  final Workout workout;
  const WorkoutHeader({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (workout.thumbnailUrl != null)
          ClipRRect(
            borderRadius: const BorderRadius.only(
              bottomLeft: Radius.circular(16),
              bottomRight: Radius.circular(16),
            ),

            child: CachedNetworkImage(
              imageUrl: workout.thumbnailUrl!,
              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: Colors.grey[200],
                height: 250,
                child: const Center(child: CircularProgressIndicator()),
              ),

              errorWidget: (context, url, error) {
                debugPrint(
                  '[WorkoutHeader] thumbnail load failed: title=${workout.title} url=$url error=$error',
                );
                return Container(
                  color: Colors.grey[200],
                  height: 250,
                  child: const Icon(Icons.image_not_supported, size: 48),
                );
              },
            ),
          ),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                workout.title,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  if (workout.level != null) ...[
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: LabelUtils.getDifficultyColor(
                          workout.level,
                        ).withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        LabelUtils.getWorkoutLevelLabel(
                          workout.level,
                        ).toUpperCase(),
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: LabelUtils.getDifficultyColor(workout.level),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                  ],
                  if (workout.estimatedDuration != null)
                    Row(
                      children: [
                        const Icon(Icons.schedule, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          '${workout.estimatedDuration} phút',
                          style: const TextStyle(fontSize: 14),
                        ),
                      ],
                    ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
