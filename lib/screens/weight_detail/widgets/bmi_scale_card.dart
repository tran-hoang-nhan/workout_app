import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class BMIScaleCard extends StatelessWidget {
  final double? currentBMI;
  const BMIScaleCard({super.key, this.currentBMI});

  double _getBMIPosition() {
    if (currentBMI == null) return 0;
    if (currentBMI! < 18.5) return (currentBMI! / 18.5) * 25;
    if (currentBMI! < 25) return 25 + ((currentBMI! - 18.5) / 6.5) * 25;
    if (currentBMI! < 30) return 50 + ((currentBMI! - 25) / 5) * 25;
    return 75 + (((currentBMI! - 30).clamp(0, 20)) / 20) * 25;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'THANG ĐO BMI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              color: AppColors.black,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 32), // Space for top indicator
          
          LayoutBuilder(
            builder: (context, constraints) {
              final scaleWidth = constraints.maxWidth;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  // The Scale Bar
                  Row(
                    children: [
                      _buildScaleSegment(const Color(0xFF60A5FA), isFirst: true),
                      _buildScaleSegment(const Color(0xFF34D399)),
                      _buildScaleSegment(const Color(0xFFFBBF24)),
                      _buildScaleSegment(const Color(0xFFF87171), isLast: true),
                    ],
                  ),
                  
                  // The Indicator
                  if (currentBMI != null)
                    Positioned(
                      left: (scaleWidth * (_getBMIPosition() / 100)) - 20,
                      top: -28,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.black,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Text(
                              currentBMI!.toStringAsFixed(1),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_drop_down_rounded, color: AppColors.black, size: 20),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
          
          const SizedBox(height: 24),

          // Legend using Wrap for maximum responsiveness
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _buildLegendItem('Thiếu cân', '< 18.5', const Color(0xFF60A5FA)),
              _buildLegendItem('Bình thường', '18.5 - 24.9', const Color(0xFF34D399)),
              _buildLegendItem('Thừa cân', '25 - 29.9', const Color(0xFFFBBF24)),
              _buildLegendItem('Béo phì', '≥ 30', const Color(0xFFF87171)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScaleSegment(Color color, {bool isFirst = false, bool isLast = false}) {
    return Expanded(
      child: Container(
        height: 12,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.horizontal(
            left: isFirst ? const Radius.circular(6) : Radius.zero,
            right: isLast ? const Radius.circular(6) : Radius.zero,
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, String range, Color color) {
    return IntrinsicWidth(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              Text(
                range,
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.grey,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
