import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';

class CalorieGoals extends StatelessWidget {
  final HealthCalculations calculations;

  const CalorieGoals({
    super.key,
    required this.calculations,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mục tiêu calo',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildCalorieGoalCard(
          'Thâm hụt Calo',
          'Giảm cân an toàn & hiệu quả',
          (calculations.tdee * 0.85).toStringAsFixed(0),
          const Color(0xFF00C6FF),
          Icons.trending_down_rounded,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildCalorieGoalCard(
          'Duy trì Cân nặng',
          'Giữ vững phong độ hiện tại',
          calculations.tdee.toStringAsFixed(0),
          const Color(0xFF10B981),
          Icons.rebase_edit,
        ),
        const SizedBox(height: AppSpacing.md),
        _buildCalorieGoalCard(
          'Dư thừa Calo',
          'Tăng cơ & Phát triển sức mạnh',
          (calculations.tdee * 1.15).toStringAsFixed(0),
          const Color(0xFFF97316),
          Icons.trending_up_rounded,
        ),
      ],
    );
  }

  Widget _buildCalorieGoalCard(
    String title,
    String subtitle,
    String value,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.black,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.grey.withValues(alpha: 0.6),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              Text(
                'CALO',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color: color.withValues(alpha: 0.5),
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
