import 'package:flutter/material.dart';
import '../../../models/body_metric.dart';
// Import file chứa các hàm tính toán
import '../../../utils/health_utils.dart'; 

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

  Color _getBMIColor(double bmi) {
    if (bmi < 18.5) return const Color(0xFF60A5FA); // Blue
    if (bmi < 25) return const Color(0xFF34D399);   // Green
    if (bmi < 30) return const Color(0xFFFBBF24);   // Yellow
    return const Color(0xFFF87171);                 // Red
  }

  @override
  Widget build(BuildContext context) {
    final bmi = calculateBMI(weight, height);
    final bmiLabel = getBMICategory(bmi); 
    final bmiColor = _getBMIColor(bmi);

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
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Cân nặng hiện tại', style: TextStyle(fontSize: 11, color: Color(0xFFFFEDD5))),
              Text('BMI', style: TextStyle(fontSize: 11, color: Color(0xFFFFEDD5))),
            ],
          ),

          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text('${weight.toStringAsFixed(1)} kg',
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  )
                ),
              ),
              Expanded(
                child: Text(bmi.toStringAsFixed(1),
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                  ),
                  textAlign: TextAlign.right
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (weightChange != null)
                _buildWeightChangeIndicator(weightChange)
              else
                const SizedBox.shrink(),

              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    bmiLabel, 
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: bmiColor
                    ),
                    textAlign: TextAlign.right,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeightChangeIndicator(double change) {
    final isIncrease = change > 0;
    final isDecrease = change < 0;
    final color = isIncrease 
        ? const Color(0xFFFCA5A5)
        : isDecrease 
            ? const Color(0xFFA7F3D0) 
            : const Color(0xFFFFEDD5); 

    final icon = isIncrease 
        ? Icons.trending_up 
        : isDecrease 
            ? Icons.trending_down 
            : Icons.remove;

    return Row(
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 3),
        Text(
          '${change.abs().toStringAsFixed(1)} kg',
          style: TextStyle(fontSize: 10, color: color),
        ),
      ],
    );
  }
}