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
          const Text('Lịch sử cân nặng',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: AppSpacing.lg),
          if (weightHistory.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.sm),
                child: Column(
                  children: [
                    Icon(Icons.calendar_today,
                        size: 36,
                        color: Colors.grey.shade700),
                    const SizedBox(height: AppSpacing.sm),
                    const Text('Chưa có dữ liệu cân nặng',
                        style: TextStyle(
                            color: AppColors.grey)),
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
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.md),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      border: Border.all(color: Colors.grey.shade300, width: 1),
                    ),
                    child: Row(
                      children: [
                        // Icon
                        Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFFF97316),
                                Color(0xFFDC2626),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Center(
                            child: Text(
                              index == 0 ? '📍' : '📊',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Wrap(
                              spacing: 4,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text(
                                  '${record.weight} kg',
                                  style: const TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.black,
                                  ),
                                ),
                                if (index == 0)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                    decoration: BoxDecoration(
                                      color: const Color(0xFFF97316),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: const Text(
                                      'Mới nhất',
                                      style: TextStyle(
                                        fontSize: 8,
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 2),
                            Text(
                              _formatDate(record.recordedAt),
                              style: const TextStyle(
                                fontSize: 10,
                                color: AppColors.grey,
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'BMI: ${recordBMI.toStringAsFixed(1)}',
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppColors.black,
                              ),
                            ),
                            const SizedBox(height: 1),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                              decoration: BoxDecoration(
                                color: (recordCategory['color'] as Color).withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Text(
                                recordCategory['label'],
                                style: TextStyle(
                                  fontSize: 10,
                                  color: recordCategory['color'],
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (weightHistory.length > 1)
                          Padding(
                            padding: const EdgeInsets.only(left: 6),
                            child: GestureDetector(
                              onTap: () => onDelete(index),
                              child: Icon(Icons.close, size: 16, color: Colors.grey.shade500),
                            ),
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
