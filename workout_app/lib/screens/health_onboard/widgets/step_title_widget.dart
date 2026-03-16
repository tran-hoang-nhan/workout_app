import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class StepTitleWidget extends StatelessWidget {
  final int currentStep;

  const StepTitleWidget({super.key, required this.currentStep});

  @override
  Widget build(BuildContext context) {
    final titles = [
      'Thông tin cá nhân',
      'Hoạt động & Mục tiêu',
      'Thói quen lối sống',
      'Tình trạng sức khỏe',
    ];

    final descriptions = [
      'Cho chúng tôi biết một chút về chỉ số cơ thể của bạn',
      'Xác định mức độ vận động để có kế hoạch phù hợp',
      'Các thói quen sinh hoạt giúp tinh chỉnh mục tiêu',
      'Thông tin y tế giúp bài tập an toàn hơn (không bắt buộc)',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titles[currentStep - 1],
          style: const TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w900,
            color: AppColors.black,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          descriptions[currentStep - 1],
          style: TextStyle(
            fontSize: 14,
            color: AppColors.grey.withValues(alpha: 0.8),
            fontWeight: FontWeight.w400,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
