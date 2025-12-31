import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';


class WaterIntakeCard extends StatelessWidget {
  final HealthFormState formState;

  const WaterIntakeCard({
    super.key,
    required this.formState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.cyan.shade400, Colors.blue.shade400],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Mục tiêu nước hàng ngày',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.cyan.shade100,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${formState.waterIntake} ml',
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: AppColors.white,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '≈ ${(formState.waterIntake / 250).toStringAsFixed(0)} ly nước mỗi ngày',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.cyan.shade100,
                    ),
                  ),
                ],
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.water_drop_outlined,
                    color: Colors.white, size: 32),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Consumer(
              builder: (context, ref, child) {
                return SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  value: formState.waterReminderEnabled,
                  onChanged: (value) async {
                    ref.read(healthFormProvider.notifier).setWaterReminderEnabled(value);
                    // Automatic save and sync
                    try {
                      await ref.read(saveHealthProfileProvider(HealthProfileSaveParams(
                        height: formState.height,
                        gender: null,
                      )).future);
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Không thể cập nhật cài đặt: $e')),
                        );
                      }
                    }
                  },
                  title: const Text(
                    'Nhắc nhở uống nước',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    'Nhắc mỗi ${formState.waterReminderInterval} giờ',
                    style: TextStyle(
                      color: Colors.cyan.shade100,
                      fontSize: 12,
                    ),
                  ),
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.cyan.shade200,
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
