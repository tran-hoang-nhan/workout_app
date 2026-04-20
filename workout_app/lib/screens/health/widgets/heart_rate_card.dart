import 'package:flutter/material.dart';
import 'package:shared/shared.dart';
import '../../../constants/app_constants.dart';

class HeartRateCard extends StatelessWidget {
  final HealthCalculations calculations;
  final double height;

  const HeartRateCard({
    super.key,
    required this.calculations,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
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
                _buildIconBox(Icons.favorite_rounded, Colors.red),
                const SizedBox(width: AppSpacing.sm),
                const Expanded(
                  child: Text(
                    'Nhịp tim',
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
            const Spacer(),
            Icon(
              Icons.favorite_rounded,
              size: 48,
              color: Colors.red.withValues(alpha: 0.8),
            ),
            const SizedBox(height: AppSpacing.sm),
            Column(
              children: [
                Text(
                  '${calculations.maxHeartRate}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Max HR (bpm)',
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.grey.withValues(alpha: 0.7),
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
            const Spacer(),
          ],
        ),
      ),
    );
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
