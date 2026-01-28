import 'package:flutter/material.dart';
import '../../../../constants/app_constants.dart';

class HeartRateInfoSection extends StatelessWidget {
  const HeartRateInfoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.blue, size: 20),
          SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              'Lưu ý: Đây chỉ là các chỉ số ước tính dựa trên công thức chuẩn. Nhịp tim thực tế có thể thay đổi tùy theo thể trạng và mức độ luyện tập của mỗi người.',
              style: TextStyle(fontSize: 12, color: Colors.blue, height: 1.5),
            ),
          ),
        ],
      ),
    );
  }
}
