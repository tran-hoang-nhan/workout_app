import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shared/shared.dart';
import '../../constants/app_constants.dart';
import '../../utils/url_utils.dart';
import '../../providers/workout_provider.dart';
import 'widgets/workout_header.dart';
import 'widgets/workout_description.dart';
import 'widgets/exercise_list_item.dart';
import '../workout_session/workout_session_screen.dart';
import '../../widgets/loading_animation.dart';

class WorkoutDetailScreen extends ConsumerStatefulWidget {
  final Workout workout;
  final WorkoutDetail? initialDetail;
  const WorkoutDetailScreen({
    super.key,
    required this.workout,
    this.initialDetail,
  });

  @override
  ConsumerState<WorkoutDetailScreen> createState() =>
      _WorkoutDetailScreenState();
}

class _WorkoutDetailScreenState extends ConsumerState<WorkoutDetailScreen> {
  @override
  void initState() {
    super.initState();
    const encoder = JsonEncoder.withIndent('  ');
    final prettyJson = encoder.convert(widget.workout.toJson());

    debugPrint('============ WORKOUT DETAIL SCREEN ============');
    debugPrint('Received Workout JSON:');
    debugPrint(prettyJson);
    debugPrint('===============================================');
  }

  @override
  Widget build(BuildContext context) {
    final workoutDetailAsync = widget.initialDetail != null
        ? AsyncValue.data(widget.initialDetail!)
        : ref.watch(workoutDetailProvider(widget.workout.id));

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: CustomScrollView(
        slivers: [
          // Premium Sliver Header with Parallax & Gradient
          SliverAppBar(
            expandedHeight: 320.0,
            pinned: true,
            stretch: true,
            backgroundColor: AppColors.primary,
            elevation: 0,
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: CircleAvatar(
                backgroundColor: AppColors.black.withValues(alpha: 0.3),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back,
                      color: AppColors.white, size: 20),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              stretchModes: const [
                StretchMode.zoomBackground,
                StretchMode.blurBackground,
              ],
              titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
              title: Text(
                widget.workout.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                  letterSpacing: -0.5,
                  shadows: [
                    Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4),
                  ],
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  if (widget.workout.thumbnailUrl != null)
                    CachedNetworkImage(
                      imageUrl: UrlUtils.sanitize(widget.workout.thumbnailUrl!),
                      fit: BoxFit.cover,
                      placeholder: (context, url) =>
                          Container(color: AppColors.greyLight),
                      errorWidget: (context, url, error) => Container(
                        color: AppColors.greyLight,
                        child: const Icon(Icons.image_not_supported,
                            color: AppColors.grey),
                      ),
                    ),
                  // Fancy Gradient Overlay
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black45,
                          Colors.black87,
                        ],
                        stops: [0.5, 0.8, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Content section
          SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WorkoutHeader(workout: widget.workout),
                if (widget.workout.description != null)
                  WorkoutDescription(description: widget.workout.description!),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 8),
                      const Text(
                        'Danh sách bài tập',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          color: AppColors.black,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      workoutDetailAsync.when(
                        data: (detail) {
                          final exercises = detail.exercises;
                          final exMap = <int, Exercise>{
                            for (final e in exercises) e.id: e,
                          };

                          final pairs = <({WorkoutItem item, Exercise ex})>[];
                          for (final it in detail.items) {
                            final ex = exMap[it.exerciseId];
                            if (ex != null) pairs.add((item: it, ex: ex));
                          }

                          if (pairs.isEmpty) {
                            return const Center(
                              child: Padding(
                                padding: EdgeInsets.symmetric(vertical: 48.0),
                                child: Text(
                                  'Chưa có bài tập nào trong set này',
                                  style: TextStyle(color: AppColors.grey),
                                ),
                              ),
                            );
                          }

                          return Column(
                            children: [
                              // Fixed Big Start Button
                              Container(
                                width: double.infinity,
                                height: 64,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(
                                      AppBorderRadius.xxl),
                                  boxShadow: [
                                    BoxShadow(
                                      color: AppColors.primary
                                          .withValues(alpha: 0.3),
                                      blurRadius: 20,
                                      offset: const Offset(0, 8),
                                    ),
                                  ],
                                ),
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => WorkoutSessionScreen(
                                          workout: widget.workout,
                                          items: pairs
                                              .map((p) => p.item)
                                              .toList(),
                                          exercises: pairs
                                              .map((p) => p.ex)
                                              .toList(),
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: AppColors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(
                                          AppBorderRadius.xxl),
                                    ),
                                    elevation: 0,
                                  ),
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.play_arrow_rounded, size: 28),
                                      SizedBox(width: 8),
                                      Text(
                                        'BẮT ĐẦU LUYỆN TẬP',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w900,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              ListView.separated(
                                shrinkWrap: true,
                                padding: const EdgeInsets.only(bottom: 120),
                                physics: const NeverScrollableScrollPhysics(),
                                itemCount: pairs.length,
                                separatorBuilder: (context, index) =>
                                    const SizedBox(height: 16),
                                itemBuilder: (context, index) {
                                  final workoutItem = pairs[index].item;
                                  final exercise = pairs[index].ex;
                                  return ExerciseListItem(
                                    exercise: exercise,
                                    workoutItem: workoutItem,
                                    currentIndex: index + 1,
                                    totalCount: pairs.length,
                                  );
                                },
                              ),
                            ],
                          );
                        },
                        loading: () => const Padding(
                          padding: EdgeInsets.symmetric(vertical: 64.0),
                          child: Center(child: AppLoading()),
                        ),
                        error: (err, stack) => Center(
                          child: Column(
                            children: [
                              const Icon(Icons.error_outline,
                                  size: 48, color: AppColors.danger),
                              const SizedBox(height: 16),
                              Text('Lỗi: $err'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
