import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:workout_app/constants/app_constants.dart';

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
  required double calories,
}) {
  return showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      return WorkoutCompletionDialogContent(
        workoutTitle: workoutTitle,
        totalItems: totalItems,
        totalSeconds: totalSeconds,
        calories: calories,
      );
    },
  );
}

class WorkoutCompletionDialogContent extends StatefulWidget {
  final String workoutTitle;
  final int totalItems;
  final int totalSeconds;
  final double calories;

  const WorkoutCompletionDialogContent({
    super.key,
    required this.workoutTitle,
    required this.totalItems,
    required this.totalSeconds,
    required this.calories,
  });

  @override
  State<WorkoutCompletionDialogContent> createState() =>
      _WorkoutCompletionDialogContentState();
}

class _WorkoutCompletionDialogContentState
    extends State<WorkoutCompletionDialogContent> {
  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      child: Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppBorderRadius.xxl),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header with Gradient
                Container(
                  width: double.infinity,
                  padding:
                      const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [AppColors.primary, AppColors.primaryLight],
                    ),
                  ),
                  child: Column(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white.withValues(alpha: 0.4), width: 2),
                        ),
                        child: const Icon(Icons.emoji_events_rounded, color: Colors.white, size: 64),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Hoàn thành bài tập!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: AppFontSize.xxxl, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        widget.workoutTitle,
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white.withValues(alpha: 0.9), fontSize: AppFontSize.md, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                // Stats Section
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 32, 24, 32),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _buildStatItem(icon: Icons.fitness_center_rounded, label: 'Bài tập', value: '${widget.totalItems}'),
                          _buildStatItem(icon: Icons.timer_rounded, label: 'Thời gian', value: _formatDuration(widget.totalSeconds)),
                          _buildStatItem(icon: Icons.local_fire_department_rounded, label: 'Tiêu hao', value: '${widget.calories.ceil()} Calo'),
                        ],
                      ),
                      const SizedBox(height: 40),
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                          boxShadow: [BoxShadow(color: AppColors.primary.withValues(alpha: 0.25), blurRadius: 15, offset: const Offset(0, 8))],
                        ),
                        child: ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            Navigator.of(context).pop();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primary,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppBorderRadius.xl)),
                          ),
                          child: const Text('Về trang chính', style: TextStyle(fontSize: AppFontSize.lg, fontWeight: FontWeight.w800)),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Positioned.fill(child: IgnorePointer(child: WorkoutCompletionConfetti())),
        ],
      ),
    ),
    );
  }

  Widget _buildStatItem({required IconData icon, required String label, required String value}) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(AppBorderRadius.lg)),
          child: Icon(icon, color: AppColors.primary, size: 28),
        ),
        const SizedBox(height: 12),
        Text(value, style: const TextStyle(fontSize: AppFontSize.xl, fontWeight: FontWeight.w800, color: AppColors.black)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: AppFontSize.sm, fontWeight: FontWeight.w600, color: AppColors.grey)),
      ],
    );
  }
}

class WorkoutCompletionConfetti extends StatefulWidget {
  const WorkoutCompletionConfetti({super.key});
  @override
  State<WorkoutCompletionConfetti> createState() => _WorkoutCompletionConfettiState();
}

class _WorkoutCompletionConfettiState extends State<WorkoutCompletionConfetti> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final List<_ConfettiParticle> _particles = [];
  final math.Random _random = math.Random();
  bool _isVisible = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 4));
    for (int i = 0; i < 60; i++) { _particles.add(_ConfettiParticle(_random)); }
    
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (mounted) {
          setState(() {
            _isVisible = false;
          });
        }
      }
    });

    _controller.forward();
    _controller.addListener(() { for (final p in _particles) { p.update(); } setState(() {}); });
  }

  @override
  void dispose() { _controller.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AnimatedOpacity(
      opacity: _isVisible ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 500),
      child: CustomPaint(painter: _ConfettiPainter(_particles)),
    );
  }
}

class _ConfettiParticle {
  late double x, y, vx, vy, size, rotation, rspeed;
  late Color color;
  final math.Random random;

  _ConfettiParticle(this.random) { reset(); y = random.nextDouble() * -200; }

  void reset() {
    x = random.nextDouble(); y = -20; vx = (random.nextDouble() - 0.5) * 0.01; vy = random.nextDouble() * 5 + 2;
    size = random.nextDouble() * 8 + 4; rotation = random.nextDouble() * math.pi * 2; rspeed = (random.nextDouble() - 0.5) * 0.2;
    final colors = [AppColors.primary, AppColors.secondary, AppColors.success, AppColors.info, Colors.orange, Colors.pinkAccent, Colors.yellowAccent];
    color = colors[random.nextInt(colors.length)];
  }

  void update() { x += vx; y += vy; rotation += rspeed; if (y > 800) reset(); }
}

class _ConfettiPainter extends CustomPainter {
  final List<_ConfettiParticle> particles;
  _ConfettiPainter(this.particles);
  @override
  void paint(Canvas canvas, Size size) {
    for (final p in particles) {
      final paint = Paint()..color = p.color..style = PaintingStyle.fill;
      canvas.save();
      final double actualX = p.x * size.width;
      canvas.translate(actualX, p.y); canvas.rotate(p.rotation);
      if (p.random.nextBool()) { canvas.drawRect(Rect.fromCenter(center: Offset.zero, width: p.size, height: p.size), paint); }
      else { canvas.drawCircle(Offset.zero, p.size / 2, paint); }
      canvas.restore();
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
