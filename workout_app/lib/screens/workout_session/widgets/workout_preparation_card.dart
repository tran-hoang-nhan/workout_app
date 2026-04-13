import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared/shared.dart';
import 'package:workout_app/constants/app_constants.dart';
import 'package:workout_app/screens/exercises/widgets/exercise_animation_widget.dart';

class WorkoutPreparationCard extends StatefulWidget {
  final String text; // "CHUẨN BỊ" 
  final String subtitle; // "BÀI TẬP ĐẦU TIÊN"
  final Exercise exercise;
  final VoidCallback onComplete;
  final bool paused;
  final int durationSeconds;

  const WorkoutPreparationCard({
    super.key,
    required this.text,
    required this.subtitle,
    required this.exercise,
    required this.onComplete,
    this.paused = false,
    this.durationSeconds = 10,
  });

  @override
  State<WorkoutPreparationCard> createState() => _WorkoutPreparationCardState();
}

class _WorkoutPreparationCardState extends State<WorkoutPreparationCard> with SingleTickerProviderStateMixin {
  late int _counter;
  late Timer _timer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _counter = widget.durationSeconds;
    
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(seconds: widget.durationSeconds),
    )..reverse(from: 1.0);

    _startCountdown();
  }

  void _startCountdown() {
    HapticFeedback.mediumImpact();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      
      if (widget.paused) {
        if (_animationController.isAnimating) {
          _animationController.stop();
        }
        return;
      } else {
        if (!_animationController.isAnimating) {
          _animationController.reverse(from: _animationController.value);
        }
      }

      if (_counter > 1) {
        setState(() {
          _counter--;
        });
        HapticFeedback.lightImpact();
      } else {
        _timer.cancel();
        widget.onComplete();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.15),
            blurRadius: 40,
            offset: const Offset(0, 20),
          ),
        ],
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.1),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
        child: Stack(
          children: [
            // 1. Background Animation (chiếm phần lớn màn hình)
            Positioned.fill(
              child: Container(
                color: AppColors.bgLight,
                child: widget.exercise.animationUrl != null && widget.exercise.animationUrl!.isNotEmpty
                    ? ExerciseAnimationWidget(
                        animationUrl: widget.exercise.animationUrl!,
                        height: double.infinity,
                        externalIsPlaying: true,
                        showControls: false,
                      )
                    : const Center(
                        child: Icon(Icons.fitness_center_rounded, size: 80, color: AppColors.cardBorder),
                      ),
              ),
            ),

            // 2. Gradient Overlay tạo độ sâu và tương phản cho chữ ở đáy
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppColors.white.withValues(alpha: 0.6),
                      AppColors.white.withValues(alpha: 0.0),
                      AppColors.white.withValues(alpha: 0.0),
                      AppColors.white.withValues(alpha: 0.8),
                      AppColors.white,
                    ],
                    stops: const [0.0, 0.2, 0.6, 0.9, 1.0],
                  ),
                ),
              ),
            ),

            // 3. Status Badge và Timer
            Positioned(
              top: 32,
              left: 0,
              right: 0,
              child: Column(
                children: [
                  // Nhãn Chuẩn bị (widget.text)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.9),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.bolt_rounded, color: AppColors.primary, size: 18),
                        const SizedBox(width: 6),
                        Text(
                          widget.text.toUpperCase(),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Vòng tròn đếm ngược
                  Container(
                    width: 90,
                    height: 90,
                    decoration: BoxDecoration(
                      color: AppColors.white.withValues(alpha: 0.8),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 90,
                          height: 90,
                          child: AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return CircularProgressIndicator(
                                value: _animationController.value,
                                strokeWidth: 6,
                                backgroundColor: AppColors.primary.withValues(alpha: 0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                                strokeCap: StrokeCap.round,
                              );
                            },
                          ),
                        ),
                        AnimatedSwitcher(
                          duration: const Duration(milliseconds: 300),
                          transitionBuilder: (Widget child, Animation<double> animation) {
                            return ScaleTransition(scale: animation, child: child);
                          },
                          child: Text(
                            '$_counter',
                            key: ValueKey<int>(_counter),
                            style: const TextStyle(
                              fontSize: 38,
                              fontWeight: FontWeight.w900,
                              color: AppColors.primary,
                              height: 1.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // 4. Nội dung tiêu đề ở dưới đáy
            Positioned(
              bottom: 32,
              left: 24,
              right: 24,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      widget.subtitle.toUpperCase(),
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 2.0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.exercise.name,
                    textAlign: TextAlign.center,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: AppColors.black,
                      height: 1.1,
                      letterSpacing: -0.5,
                    ),
                  ),
                  if (widget.exercise.description != null && widget.exercise.description!.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Text(
                      widget.exercise.description!,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: AppColors.black.withValues(alpha: 0.5),
                        height: 1.4,
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
}

