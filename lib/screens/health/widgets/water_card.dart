import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/progress_user_provider.dart';
import '../../../widgets/add_water_dialog.dart';

class WaterCard extends ConsumerWidget {
  final int currentCups;
  final int waterGoal;
  final double height;

  const WaterCard({
    super.key,
    required this.currentCups,
    required this.waterGoal,
    required this.height,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isCompleted = waterGoal > 0 && currentCups >= waterGoal;
    final progress = (waterGoal > 0) ? (currentCups / waterGoal).clamp(0.0, 1.0) : 0.0;
    final remaining = (waterGoal - currentCups).clamp(0, waterGoal);

    return Expanded(
      child: Container(
        height: height,
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: _cardDecoration(),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                _buildIconBox(Icons.local_drink, Colors.blue.shade500),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text(
                    'Nước uống',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
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
                            isCompleted ? 'Hoàn thành!' : 'Còn $remaining ly',
                            style: TextStyle(
                              fontSize: 11,
                              color: isCompleted
                                  ? Colors.green.shade600
                                  : AppColors.grey,
                              fontWeight: isCompleted
                                  ? FontWeight.bold
                                  : FontWeight.normal,
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
                            tween: Tween(begin: 0, end: progress.toDouble()),
                            duration: const Duration(milliseconds: 1000),
                            curve: Curves.easeInOutCubic,
                            builder: (context, value, child) {
                              return CustomPaint(
                                painter: _WaterCupPainter(
                                  progress: value,
                                  isCompleted: isCompleted,
                                ),
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
                _buildWaterButton(
                  Icons.remove,
                  () => _updateWaterCup(context, ref, -1),
                ),
                const SizedBox(width: 8),
                _buildWaterButton(
                  Icons.add,
                  () => _updateWaterCup(context, ref, 1),
                  isPrimary: true,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _updateWaterCup(BuildContext context, WidgetRef ref, int deltaCups) async {
    try {
      if (deltaCups > 0) {
        if (!context.mounted) return;
        final amount = await AddWaterDialog.show(context);
        if (amount != null && amount > 0 && context.mounted) {
          await ref.read(progressUserControllerProvider.notifier).updateWater(amount);
        }
      } else {
        if (currentCups <= 0) return;
        final deltaMl = deltaCups * 250;
        await ref.read(progressUserControllerProvider.notifier).updateWater(deltaMl);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
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
            boxShadow: isPrimary
                ? [
                    BoxShadow(
                      color: Colors.blue.shade500.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ]
                : null,
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
}

class _WaterCupPainter extends CustomPainter {
  final double progress;
  final bool isCompleted;

  _WaterCupPainter({required this.progress, this.isCompleted = false});

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
        colors: isCompleted
            ? [Colors.green.shade700, Colors.green.shade400]
            : [Colors.blue.shade700, Colors.blue.shade400],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final path = Path()
      ..moveTo(size.width * 0.1, 0)
      ..lineTo(size.width * 0.9, 0)
      ..lineTo(size.width * 0.8, size.height)
      ..lineTo(size.width * 0.2, size.height)
      ..close();

    canvas.drawPath(path, paint);

    if (progress > 0) {
      final liquidHeight = size.height * progress;
      final liquidTop = size.height - liquidHeight;
      final liquidPath = Path()
        ..moveTo(size.width * (0.2 - (0.1 * progress)), liquidTop)
        ..lineTo(size.width * (0.8 + (0.1 * progress)), liquidTop)
        ..lineTo(size.width * 0.8, size.height)
        ..lineTo(size.width * 0.2, size.height)
        ..close();

      canvas.drawPath(liquidPath, liquidPaint);
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

    canvas.drawPath(path, borderPaint);
  }

  @override
  bool shouldRepaint(covariant _WaterCupPainter oldDelegate) => oldDelegate.progress != progress;
}
