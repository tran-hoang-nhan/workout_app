import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';

import '../../../models/health_params.dart';

class WaterIntakeCard extends StatelessWidget {
  final HealthUpdateParams formState;

  const WaterIntakeCard({super.key, required this.formState});

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
              Expanded(
                child: Column(
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
                        fontSize: 22,
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
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.water_drop_outlined,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 4,
            ),
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
                    ref
                        .read(healthFormProvider.notifier)
                        .setWaterReminderEnabled(value);
                    // Automatic save and sync
                    try {
                      await ref.read(
                        saveHealthProfileProvider((
                          height: formState.height,
                          gender: null,
                        )).future,
                      );
                    } catch (e) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Không thể cập nhật cài đặt: $e'),
                          ),
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
                    style: TextStyle(color: Colors.cyan.shade100, fontSize: 12),
                  ),
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.cyan.shade200,
                );
              },
            ),
          ),
          if (formState.waterReminderEnabled) ...[
            const SizedBox(height: AppSpacing.md),
            Consumer(
              builder: (context, ref, child) {
                return Row(
                  children: [
                    Expanded(
                      child: _buildTimeSelector(
                        context,
                        'Thức dậy',
                        formState.wakeTime,
                        (newTime) async {
                          ref
                              .read(healthFormProvider.notifier)
                              .setWakeTime(newTime);
                          await _saveSettings(ref);
                        },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: _buildTimeSelector(
                        context,
                        'Đi ngủ',
                        formState.sleepTime,
                        (newTime) async {
                          ref
                              .read(healthFormProvider.notifier)
                              .setSleepTime(newTime);
                          await _saveSettings(ref);
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Future<void> _saveSettings(WidgetRef ref) async {
    try {
      await ref.read(
        saveHealthProfileProvider((
          height: formState.height,
          gender: null,
        )).future,
      );
    } catch (e) {
      // Error handling is managed by the provider/ui usually
      debugPrint('Error saving water times: $e');
    }
  }

  Widget _buildTimeSelector(
    BuildContext context,
    String label,
    String currentTime,
    Function(String) onChanged,
  ) {
    return InkWell(
      onTap: () async {
        final parts = currentTime.split(':');
        final initialTime = TimeOfDay(
          hour: int.parse(parts[0]),
          minute: int.parse(parts[1]),
        );

        final picked = await showTimePicker(
          context: context,
          initialTime: initialTime,
          builder: (context, child) {
            return Theme(
              data: Theme.of(context).copyWith(
                colorScheme: ColorScheme.light(
                  primary: Colors.cyan.shade600,
                  onPrimary: Colors.white,
                  surface: Colors.white,
                  onSurface: Colors.black,
                ),
              ),
              child: child!,
            );
          },
        );

        if (picked != null) {
          final formattedTime =
              '${picked.hour.toString().padLeft(2, '0')}:${picked.minute.toString().padLeft(2, '0')}';
          onChanged(formattedTime);
        }
      },
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(color: Colors.cyan.shade100, fontSize: 10),
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.access_time, color: Colors.white, size: 14),
                const SizedBox(width: 4),
                Text(
                  currentTime,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
