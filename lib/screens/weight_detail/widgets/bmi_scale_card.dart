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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.cardBorder),
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
          const Text('Thang đo BMI',
              style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: 8),
          
          Stack(
            children: [
              Row(
                children: [
                  // Thiếu cân (< 18.5)
                  Expanded(
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFF60A5FA),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          bottomLeft: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                  // Bình thường (18.5-24.9)
                  Expanded(
                    child: Container(
                      height: 24,
                      color: const Color(0xFF34D399),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 24,
                      color: const Color(0xFFFBBF24),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      height: 24,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF87171),
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(12),
                          bottomRight: Radius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              
              // Current BMI Indicator
              if (currentBMI != null)
                Positioned(
                  left: MediaQuery.of(context).size.width * (_getBMIPosition() / 100) - 32,
                  top: 0,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.2),
                              blurRadius: 2,
                            ),
                          ],
                        ),
                        child: Text(
                          currentBMI!.toStringAsFixed(1),
                          style: const TextStyle(
                            color: Color(0xFF111827),
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      // Indicator line
                      Container(
                        width: 2,
                        height: 24,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.3),
                              blurRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 3.2,
            children: [
              _buildCategoryItem('Thiếu cân', '< 18.5', const Color(0xFF60A5FA)),
              _buildCategoryItem('Bình thường', '18.5 - 24.9', const Color(0xFF34D399)),
              _buildCategoryItem('Thừa cân', '25 - 29.9', const Color(0xFFFBBF24)),
              _buildCategoryItem('Béo phì', '≥ 30', const Color(0xFFF87171)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryItem(String label, String range, Color color) {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppBorderRadius.md),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  range,
                  style: const TextStyle(
                    fontSize: 8,
                    color: AppColors.grey,
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
