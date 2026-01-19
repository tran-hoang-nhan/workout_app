import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:health/health.dart';
import 'package:intl/intl.dart';
import '../../../constants/app_constants.dart';

class HeartRateHeader extends StatelessWidget {
  final AsyncValue<List<HealthDataPoint>> dataAsync;
  const HeartRateHeader({super.key, required this.dataAsync});

  @override
  Widget build(BuildContext context) {
    return dataAsync.when(
      data: (data) {
        final latestBPM = data.isNotEmpty 
          ? double.tryParse(data.last.value.toString())?.toInt() ?? 0
          : 0;
        final latestTime = data.isNotEmpty 
          ? DateFormat('HH:mm').format(data.last.dateFrom)
          : '--:--';
        return Padding(
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Nhịp tim gần nhất',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.grey,
                ),
              ),
              const SizedBox(height: 8),
              Row(
                crossAxisAlignment: CrossAxisAlignment.baseline,
                textBaseline: TextBaseline.alphabetic,
                children: [
                  Text(
                    latestBPM.toString(),
                    style: const TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'BPM',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.danger,
                    ),
                  ),
                ],
              ),
              Text(
                'Đo lúc $latestTime',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.grey.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => const SizedBox(height: 100, child: Center(child: CircularProgressIndicator())),
      error: (_, _) => const SizedBox.shrink(),
    );
  }
}
