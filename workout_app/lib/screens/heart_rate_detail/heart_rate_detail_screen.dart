import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/health_provider.dart';
import 'widgets/max_hr_card.dart';
import 'widgets/zone_detail_card.dart';
import 'widgets/heart_rate_info_section.dart';

class HeartRateDetailScreen extends ConsumerWidget {
  const HeartRateDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final calculations = ref.watch(healthCalculationsProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      appBar: AppBar(
        title: const Text(
          'Nhịp tim & Vùng tập luyện',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            MaxHRCard(maxHR: calculations.maxHeartRate),
            const SizedBox(height: 24),
            ZoneDetailCard(
              title: 'Vùng 1: Khởi động (50-60%)',
              range:
                  '${calculations.zone1.min} - ${calculations.zone1.max} bpm',
              percentage: '50-60%',
              description: 'Tốt cho phục hồi và làm nóng cơ thể.',
              color: Colors.grey[400]!,
              icon: Icons.directions_walk_rounded,
            ),
            const SizedBox(height: 12),
            ZoneDetailCard(
              title: 'Vùng 2: Đốt mỡ (60-70%)',
              range:
                  '${calculations.zone2.min} - ${calculations.zone2.max} bpm',
              percentage: '60-70%',
              description: 'Tăng cường sức bền cơ bản và đốt cháy chất béo.',
              color: Colors.blue,
              icon: Icons.run_circle_rounded,
            ),
            const SizedBox(height: 12),
            ZoneDetailCard(
              title: 'Vùng 3: Aerobic (70-80%)',
              range:
                  '${calculations.zone3.min} - ${calculations.zone3.max} bpm',
              percentage: '70-80%',
              description: 'Cải thiện hệ thống tim mạch và sức mạnh cơ bắp.',
              color: Colors.green,
              icon: Icons.directions_run_rounded,
            ),
            const SizedBox(height: 12),
            ZoneDetailCard(
              title: 'Vùng 4: Anaerobic (80-90%)',
              range:
                  '${calculations.zone4.min} - ${calculations.zone4.max} bpm',
              percentage: '80-90%',
              description: 'Tăng cường hiệu suất tối đa và ngưỡng lactate.',
              color: Colors.orange,
              icon: Icons.speed_rounded,
            ),
            const SizedBox(height: 12),
            ZoneDetailCard(
              title: 'Vùng 5: Redline (90-100%)',
              range:
                  '${calculations.zone5.min} - ${calculations.zone5.max} bpm',
              percentage: '90-100%',
              description: 'Dùng cho các khoảng thời gian tập luyện cực ngắn.',
              color: Colors.red,
              icon: Icons.whatshot_rounded,
            ),
            const SizedBox(height: 32),
            const HeartRateInfoSection(),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}
