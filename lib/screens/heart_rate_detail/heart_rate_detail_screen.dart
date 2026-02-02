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
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            40,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Row(
                  children: [
                    Icon(Icons.arrow_back, color: AppColors.grey, size: 24),
                    SizedBox(width: AppSpacing.md),
                    Text(
                      'Quay lại',
                      style: TextStyle(color: AppColors.grey, fontSize: 14),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              const Text(
                'Vùng Nhịp Tim',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.xs),
              const Text(
                'Tối ưu hóa quá trình tập luyện của bạn',
                style: TextStyle(color: AppColors.grey, fontSize: 14),
              ),

              const SizedBox(height: AppSpacing.xl),

              // Max Heart Rate Card
              MaxHRCard(maxHR: calculations.maxHeartRate),

              const SizedBox(height: AppSpacing.xl),

              const Text(
                'Chi tiết các vùng tập luyện',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Zone 1: Warm Up
              ZoneDetailCard(
                title: 'Vùng 1: Khởi động (Warm Up)',
                range: '${calculations.zone1.min} - ${calculations.zone1.max} bpm',
                percentage: '50% - 60%',
                description: 'Lý tưởng để khởi động, phục hồi sau tập luyện hoặc cho người mới bắt đầu.',
                color: Colors.blue.shade400,
                icon: Icons.directions_walk_rounded,
              ),

              const SizedBox(height: AppSpacing.md),

              // Zone 2: Fat Burn
              ZoneDetailCard(
                title: 'Vùng 2: Đốt mỡ (Fat Burn)',
                range: '${calculations.zone2.min} - ${calculations.zone2.max} bpm',
                percentage: '60% - 70%',
                description: 'Tốt nhất để giảm cân và tăng cường sức bền cơ bản. Cơ thể sử dụng chất béo làm nguồn năng lượng chính.',
                color: const Color(0xFFF97316),
                icon: Icons.local_fire_department_rounded,
              ),

              const SizedBox(height: AppSpacing.md),

              // Zone 3: Cardio
              ZoneDetailCard(
                title: 'Vùng 3: Cardio (Aerobic)',
                range: '${calculations.zone3.min} - ${calculations.zone3.max} bpm',
                percentage: '70% - 80%',
                description: 'Cải thiện hệ thống tim mạch và hô hấp. Tăng cường khả năng vận chuyển oxy đến cơ bắp.',
                color: const Color(0xFFEF4444),
                icon: Icons.favorite_rounded,
              ),

              const SizedBox(height: AppSpacing.md),

              // Zone 4: Anaerobic
              ZoneDetailCard(
                title: 'Vùng 4: Sức mạnh (Anaerobic)',
                range: '${calculations.zone4.min} - ${calculations.zone4.max} bpm',
                percentage: '80% - 90%',
                description: 'Tăng cường sức mạnh và tốc độ. Cải thiện khả năng chịu đựng của cơ bắp với axit lactic.',
                color: Colors.purple.shade400,
                icon: Icons.bolt_rounded,
              ),

              const SizedBox(height: AppSpacing.md),

              // Zone 5: Vùng Đỏ (Red Line)
              ZoneDetailCard(
                title: 'Vùng 5: Vùng Đỏ (Red Line)',
                range: '${calculations.zone5.min} - ${calculations.zone5.max} bpm',
                percentage: '90% - 100%',
                description: 'Nỗ lực tối đa trong thời gian ngắn. Chỉ dành cho vận động viên chuyên nghiệp hoặc các bài tập HIIT cường độ cực cao.',
                color: Colors.black87,
                icon: Icons.warning_rounded,
              ),

              const SizedBox(height: AppSpacing.xl),
              const HeartRateInfoSection(),
            ],
          ),
        ),
      ),
    );
  }
}
