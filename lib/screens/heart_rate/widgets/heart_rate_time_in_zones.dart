import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../models/daily_summary.dart';
import './heart_rate_zone_bar.dart';

class HeartRateTimeInZones extends StatelessWidget {
  final AsyncValue<Map<String, int>> zonesAsync;
  final AsyncValue<DailySummary?> summaryAsync;

  const HeartRateTimeInZones({
    super.key,
    required this.zonesAsync,
    required this.summaryAsync,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thời gian trong các vùng',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: 16),
          zonesAsync.when(
            data: (zones) {
              var displayZones = zones;
              if (zones.values.every((v) => v == 0)) {
                final summary = summaryAsync.value;
                if (summary != null && summary.heartRateZones.isNotEmpty) {
                  displayZones = summary.heartRateZones.map((k, v) => MapEntry(k, v as int));
                }
              }

              final totalMinutes = displayZones.values.fold(0, (sum, val) => sum + val);
              
              return Container(
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Column(
                  children: [
                    HeartRateZoneBar(label: 'Vùng đốt mỡ', minutes: displayZones['Fat Burn'] ?? 0, totalMinutes: totalMinutes, color: Colors.orange),
                    const SizedBox(height: 16),
                    HeartRateZoneBar(label: 'Vùng Cardio', minutes: displayZones['Cardio'] ?? 0, totalMinutes: totalMinutes, color: Colors.red),
                    const SizedBox(height: 16),
                    HeartRateZoneBar(label: 'Vùng Đỉnh', minutes: displayZones['Peak'] ?? 0, totalMinutes: totalMinutes, color: Colors.deepOrangeAccent),
                  ],
                ),
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Lỗi: $e')),
          ),
        ],
      ),
    );
  }
}
