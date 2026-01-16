import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../models/body_metric.dart';
import '../../../utils/health_utils.dart';

class WeightHistoryCard extends StatelessWidget {
  final List<BodyMetric> weightHistory;
  final double height;
  final Function(int) onDelete;

  const WeightHistoryCard({
    super.key,
    required this.weightHistory,
    required this.height,
    required this.onDelete,
  });

  Map<String, dynamic> _getBMICategory(double bmi) {
    if (bmi < 18.5) {
      return {
        'label': 'Thiếu cân',
        'color': const Color(0xFF60A5FA),
        'range': '< 18.5'
      };
    } else if (bmi < 25) {
      return {
        'label': 'Bình thường',
        'color': const Color(0xFF34D399),
        'range': '18.5 - 24.9'
      };
    } else if (bmi < 30) {
      return {
        'label': 'Thừa cân',
        'color': const Color(0xFFFBBF24),
        'range': '25 - 29.9'
      };
    } else {
      return {
        'label': 'Béo phì',
        'color': const Color(0xFFF87171),
        'range': '≥ 30'
      };
    }
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
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
          const Text(
            'Lịch sử cân nặng',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.black)),
          const SizedBox(height: AppSpacing.lg),
          if (weightHistory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Column(
                  children: [
                    Icon(Icons.calendar_today, size: 36, color: Colors.grey.shade700),
                    const SizedBox(height: AppSpacing.sm),
                    const Text('Chưa có dữ liệu cân nặng', style: TextStyle(color: AppColors.grey)),
                  ],
                ),
              ),
            )
          else
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: weightHistory.length,
              itemBuilder: (context, index) {
                final record = weightHistory[index];
                final recordBMI = calculateBMI(record.weight, height);
                final recordCategory = _getBMICategory(recordBMI);
                
                // Calculate weight change compared to previous record (the one after it in the list)
                double? change;
                if (index + 1 < weightHistory.length) {
                  change = record.weight - weightHistory[index + 1].weight;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.02),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.monitor_weight_outlined, color: AppColors.primary, size: 24),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                _formatDate(record.recordedAt),
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.black,
                                ),
                              ),
                              Row(
                                children: [
                                  Text(
                                    'BMI: ${recordBMI.toStringAsFixed(1)}',
                                    style: const TextStyle(fontSize: 12, color: AppColors.grey, fontWeight: FontWeight.w500),
                                  ),
                                  const SizedBox(width: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: (recordCategory['color'] as Color).withValues(alpha: 0.1),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      recordCategory['label'],
                                      style: TextStyle(fontSize: 9, color: recordCategory['color'], fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${record.weight} kg',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w900,
                                color: AppColors.black,
                              ),
                            ),
                            if (change != null && change != 0)
                              Row(
                                children: [
                                  Icon(
                                    change > 0 ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
                                    size: 12,
                                    color: change > 0 ? Colors.red : Colors.green,
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    '${change.abs().toStringAsFixed(1)} kg',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: change > 0 ? Colors.red : Colors.green,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => onDelete(index),
                          child: Icon(Icons.close, size: 18, color: Colors.grey.shade400),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
        ],
      ),
    );
  }
}
