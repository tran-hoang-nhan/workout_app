import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';

class StepsWaterCards extends ConsumerStatefulWidget {
  const StepsWaterCards({super.key});

  @override
  ConsumerState<StepsWaterCards> createState() => _StepsWaterCardsState();
}

class _StepsWaterCardsState extends ConsumerState<StepsWaterCards> {
  static const int stepsGoal = 10000;
  static const int waterGoal = 8;

  @override
  Widget build(BuildContext context) {
    final healthDataAsync = ref.watch(healthDataProvider);
    final formState = ref.watch(healthFormProvider);
    final waterCups = (formState.waterIntake / 250).floor(); // Derived or maintained locally if not synced

    return healthDataAsync.when(
      loading: () => _buildLoadingState(),
      error: (err, stack) => _buildErrorState(err.toString()),
      data: (data) => Row(
        children: [
          _buildStepsCard(data?.steps ?? 0),
          const SizedBox(width: AppSpacing.md),
          _buildWaterCard(waterCups),
        ],
      ),
    );
  }

  Widget _buildStepsCard(int steps) {
    final progress = (steps / stepsGoal).clamp(0.0, 1.0);
    final percentage = (progress * 100).toInt();

    return Expanded(
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildIconBox(Icons.directions_walk, AppColors.primary),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Bước chân',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            Stack(
              alignment: Alignment.center,
              children: [
                SizedBox(
                  width: 80,
                  height: 80,
                  child: CircularProgressIndicator(
                    value: progress,
                    strokeWidth: 10,
                    backgroundColor: Colors.orange.shade50,
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                    strokeCap: StrokeCap.round,
                  ),
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '$percentage%',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  steps.toString(),
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  'Mục tiêu: $stepsGoal',
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.grey.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWaterCard(int currentCups) {
    final progress = (currentCups / waterGoal).clamp(0.0, 1.0);
    final remaining = (waterGoal - currentCups).clamp(0, waterGoal);

    return Expanded(
      child: Container(
        height: 220,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildIconBox(Icons.local_drink, Colors.blue.shade500),
                const SizedBox(width: AppSpacing.sm),
                const Text(
                  'Nước uống',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '$currentCups/$waterGoal',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.black,
                            ),
                          ),
                          Text(
                            remaining > 0 ? 'Còn $remaining ly' : 'Đã hoàn thành!',
                            style: TextStyle(
                              fontSize: 11,
                              color: remaining > 0 ? AppColors.grey : Colors.green.shade600,
                              fontWeight: remaining > 0 ? FontWeight.normal : FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: Center(
                        child: SizedBox(
                          width: 60,
                          height: 80,
                          child: TweenAnimationBuilder<double>(
                            tween: Tween(begin: 0, end: progress),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeInOutCubic,
                            builder: (context, value, child) {
                              return CustomPaint(
                                painter: _WaterCupPainter(progress: value),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Row(
              children: [
                _buildWaterButton(Icons.remove, () => _updateWaterCup(ref, -1)),
                const SizedBox(width: 8),
                _buildWaterButton(Icons.add, () => _updateWaterCup(ref, 1), isPrimary: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateWaterCup(WidgetRef ref, int delta) {
    final currentState = ref.read(healthFormProvider);
    final currentMl = currentState.waterIntake;
    final newMl = (currentMl + (delta * 250)).clamp(0.0, 5000.0);
    ref.read(healthFormProvider.notifier).setWaterIntake(newMl);
  }

  Widget _buildIconBox(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 18),
    );
  }

  Widget _buildWaterButton(IconData icon, VoidCallback onTap, {bool isPrimary = false}) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: isPrimary ? Colors.blue.shade500 : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isPrimary ? Colors.blue.shade500 : Colors.blue.shade100,
            ),
            boxShadow: isPrimary ? [
              BoxShadow(
                color: Colors.blue.shade500.withValues(alpha: 0.2),
                blurRadius: 4,
                offset: const Offset(0, 2),
              )
            ] : null,
          ),
          child: Icon(
            icon,
            size: 16,
            color: isPrimary ? Colors.white : Colors.blue.shade500,
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(24),
      border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
      boxShadow: [
        BoxShadow(
          color: AppColors.black.withValues(alpha: 0.03),
          blurRadius: 15,
          offset: const Offset(0, 8),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return const SizedBox(
      height: 220,
      child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
    );
  }

  Widget _buildErrorState(String error) {
    return Container(
      height: 220,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: _cardDecoration(),
      child: Center(
        child: Text(
          'Lỗi tải dữ liệu: $error',
          style: const TextStyle(color: Colors.red, fontSize: 12),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

class _WaterCupPainter extends CustomPainter {
  final double progress;

  _WaterCupPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.shade100.withValues(alpha: 0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.blue.shade200
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5;

    final liquidPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.bottomCenter,
        end: Alignment.topCenter,
        colors: [Colors.blue.shade700, Colors.blue.shade400],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    // Draw Cup Background
    final path = Path()
      ..moveTo(size.width * 0.1, 0)
      ..lineTo(size.width * 0.9, 0)
      ..lineTo(size.width * 0.8, size.height)
      ..lineTo(size.width * 0.2, size.height)
      ..close();

    canvas.drawPath(path, paint);

    // Draw Liquid
    if (progress > 0) {
      final liquidHeight = size.height * progress;
      final liquidTop = size.height - liquidHeight;
      
      // Calculate liquid path based on progress (cup is wider at top)
      final liquidPath = Path()
        ..moveTo(size.width * (0.2 - (0.1 * progress)), liquidTop)
        ..lineTo(size.width * (0.8 + (0.1 * progress)), liquidTop)
        ..lineTo(size.width * 0.8, size.height)
        ..lineTo(size.width * 0.2, size.height)
        ..close();
      
      canvas.drawPath(liquidPath, liquidPaint);

      // Add a subtle shine to the liquid surface
      final surfacePaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1;
      canvas.drawLine(
        Offset(size.width * (0.2 - (0.1 * progress)), liquidTop),
        Offset(size.width * (0.8 + (0.1 * progress)), liquidTop),
        surfacePaint,
      );
    }

    // Draw Cup Outline
    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _WaterCupPainter oldDelegate) => 
      oldDelegate.progress != progress;
}
