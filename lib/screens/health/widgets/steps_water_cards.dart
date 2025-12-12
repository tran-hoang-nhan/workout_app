import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';

class StepsWaterCards extends ConsumerStatefulWidget {
  const StepsWaterCards({super.key});

  @override
  ConsumerState<StepsWaterCards> createState() => _StepsWaterCardsState();
}

class _StepsWaterCardsState extends ConsumerState<StepsWaterCards> {
  int steps = 0;
  int waterCups = 0;
  static const int stepsGoal = 10000;
  static const int waterGoal = 8;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    // TODO: Load từ health service nếu có
    setState(() {
      steps = 0;
      waterCups = 0;
    });
  }

  void _updateSteps(int delta) {
    setState(() {
      steps = (steps + delta).clamp(0, 99999);
    });
  }

  void _updateWater(int delta) {
    setState(() {
      waterCups = (waterCups + delta).clamp(0, 16);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Steps Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1A3F),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(color: const Color(0xFF1A3A5F)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFFFF7F00), Color(0xFFFF0000)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: const Icon(
                    Icons.directions_walk,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  steps.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Bước chân',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (steps / stepsGoal).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade800,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFFFF7F00)),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateSteps(-1000),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '-1K',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateSteps(1000),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF7F00),
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '+1K',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Mục tiêu: ${stepsGoal.toString()}',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        // Water Card
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1A3F),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
              border: Border.all(color: const Color(0xFF1A3A5F)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Color(0xFF00CCFF), Color(0xFF0066FF)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                  child: const Icon(
                    Icons.local_drink,
                    color: Colors.white,
                    size: 22,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  waterCups.toString(),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                const SizedBox(height: 2),
                const Text(
                  'Ly nước',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.grey,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Progress Bar
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: (waterCups / waterGoal).clamp(0.0, 1.0),
                    minHeight: 6,
                    backgroundColor: Colors.grey.shade800,
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(Color(0xFF00CCFF)),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateWater(-1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.grey.shade800,
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '-1',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _updateWater(1),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF00CCFF),
                          padding: const EdgeInsets.symmetric(
                              vertical: AppSpacing.sm),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          '+1',
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Mục tiêu: ${waterGoal} ly/ngày',
                  style: const TextStyle(
                    fontSize: 10,
                    color: AppColors.grey,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
