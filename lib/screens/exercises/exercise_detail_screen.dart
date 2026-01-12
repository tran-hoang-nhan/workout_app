import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/exercise.dart';
import 'widgets/exercise_animation_widget.dart';

class ExerciseDetailScreen extends StatefulWidget {
  final Exercise exercise;

  const ExerciseDetailScreen({
    super.key,
    required this.exercise,
  });

  @override
  State<ExerciseDetailScreen> createState() => _ExerciseDetailScreenState();
}

class _ExerciseDetailScreenState extends State<ExerciseDetailScreen> {

  @override
  Widget build(BuildContext context) {
    final hasAnimation = widget.exercise.animationUrl != null && widget.exercise.animationUrl!.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.exercise.name),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media Section
            if (hasAnimation)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ExerciseAnimationWidget(
                  animationUrl: widget.exercise.animationUrl!,
                  height: 350,
                ),
              )
            else if (widget.exercise.thumbnailUrl != null)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: widget.exercise.thumbnailUrl!,
                    height: 300,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => Container(
                      color: Colors.grey[200],
                      child: const Center(child: CircularProgressIndicator()),
                    ),
                    errorWidget: (context, url, error) => Container(
                      color: Colors.grey[200],
                      child: const Icon(Icons.image_not_supported, size: 48),
                    ),
                  ),
                ),
              )
            else
              // Fallback khi không có animation và thumbnail
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.fitness_center, size: 48, color: Colors.grey),
                        SizedBox(height: 8),
                        Text(
                          'Chưa có hình ảnh hướng dẫn',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Exercise Info
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.exercise.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  if (widget.exercise.muscleGroup != null) ...[
                    _buildInfoRow(
                      icon: Icons.fitness_center,
                      label: 'Nhóm cơ',
                      value: widget.exercise.muscleGroup!,
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  if (widget.exercise.difficulty != null) ...[
                    _buildInfoRow(
                      icon: Icons.speed,
                      label: 'Độ khó',
                      value: widget.exercise.difficulty!,
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  if (widget.exercise.caloriesPerMinute != null) ...[
                    _buildInfoRow(
                      icon: Icons.local_fire_department,
                      label: 'Calories/phút',
                      value: '${widget.exercise.caloriesPerMinute!.toStringAsFixed(1)} kcal',
                    ),
                    const SizedBox(height: 12),
                  ],
                  
                  if (widget.exercise.description != null) ...[
                    const Divider(height: 32),
                    const Text(
                      'Mô tả',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      widget.exercise.description!,
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[700],
                        height: 1.5,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Theme.of(context).primaryColor),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey[700],
          ),
        ),
      ],
    );
  }
}
