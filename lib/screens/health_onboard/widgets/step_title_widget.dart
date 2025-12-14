import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class StepTitleWidget extends StatelessWidget {
  final int currentStep;

  const StepTitleWidget({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Thông tin cơ bản',
      'Hoạt động & Mục tiêu',
      'Lối sống',
      'Sức khỏe',
    ];

    final descriptions = [
      'Cho chúng tôi biết về bạn',
      'Mức độ vận động và mục tiêu của bạn',
      'Thói quen sinh hoạt hàng ngày',
      'Tình trạng sức khỏe hiện tại (có thể bỏ qua)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titles[currentStep - 1],
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          descriptions[currentStep - 1],
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade400,
          ),
        ),
      ],
    );
  }
}
