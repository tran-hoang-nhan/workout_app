import 'package:flutter/material.dart';
import '../../../models/body_metric.dart';

class CurrentWeightCard extends StatelessWidget {
  final double weight;
  final double height;
  final List<BodyMetric> weightHistory;

  const CurrentWeightCard({
    super.key,
    required this.weight,
    required this.height,
    required this.weightHistory,
  });

  double _calculateBMI(double w) {
    final heightInMeters = height / 100;
    return w / (heightInMeters * heightInMeters);
  }

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

  @override
  Widget build(BuildContext context) {
    final bmi = _calculateBMI(weight);
    final bmiCategory = _getBMICategory(bmi);
    final weightChange = weightHistory.length >= 2
        ? weightHistory[0].weight - weightHistory[1].weight
        : null;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFF97316), Color(0xFFDC2626)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Cân nặng hiện tại',
                  style: TextStyle(
                      fontSize: 11, color: Color(0xFFFFEDD5))),
              const Text('BMI',
                  style: TextStyle(
                      fontSize: 11,
                      color: Color(0xFFFFEDD5))),
            ],
          ),
          const SizedBox(height: 4),
          // Values Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - Weight
              Expanded(
                child: Text('${weight.toStringAsFixed(1)} kg',
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white)),
              ),
              // Right side - BMI
              Expanded(
                child: Text(bmi.toStringAsFixed(1),
                    style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.white),
                    textAlign: TextAlign.right),
              ),
            ],
          ),
          const SizedBox(height: 4),
          // Footer Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side - Weight change
              if (weightChange != null)
                Row(
                  children: [
                    Icon(
                      weightChange > 0
                          ? Icons.trending_up
                          : weightChange < 0
                              ? Icons.trending_down
                              : Icons.remove,
                      size: 14,
                      color: weightChange > 0
                          ? const Color(0xFFFCA5A5)
                          : weightChange < 0
                              ? const Color(0xFFA7F3D0)
                              : const Color(0xFFFFEDD5),
                    ),
                    const SizedBox(width: 3),
                    Text(
                      '${weightChange.abs().toStringAsFixed(1)} kg',
                      style: TextStyle(
                        fontSize: 10,
                        color: weightChange > 0
                            ? const Color(0xFFFCA5A5)
                            : weightChange < 0
                                ? const Color(0xFFA7F3D0)
                                : const Color(0xFFFFEDD5),
                      ),
                    ),
                  ],
                )
              else
                const SizedBox.shrink(),
              // Right side - BMI Category
              Text(
                bmiCategory['label'],
                style: const TextStyle(
                    fontSize: 11,
                    color: Color(0xFFFFEDD5)),
                textAlign: TextAlign.right,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
