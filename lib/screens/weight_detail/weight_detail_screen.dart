import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/weight_provider.dart';
import 'widgets/current_weight_card.dart';
import 'widgets/bmi_scale_card.dart';
import 'widgets/add_weight_form.dart';
import 'widgets/weight_history_card.dart';
import 'widgets/weight_progress_chart.dart';
import 'widgets/weight_achievements_card.dart';

class WeightDetailScreen extends ConsumerWidget {
  const WeightDetailScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final weightDataAsync = ref.watch(loadWeightDataProvider);

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: weightDataAsync.when(
          data: (weightData) => SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 40),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const Row(
                    children: [
                      Icon(Icons.arrow_back, color: AppColors.grey, size: 24),
                      SizedBox(width: AppSpacing.md),
                      Text('Quay lại', style: TextStyle(color: AppColors.grey, fontSize: 14)),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Cân nặng & BMI',
                   style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.black),
                ),
                const SizedBox(height: AppSpacing.xs),
                const Text(
                  'Theo dõi cân nặng và chỉ số BMI của bạn',
                  style: TextStyle(color: AppColors.grey, fontSize: 14),
                ),
                
                const SizedBox(height: AppSpacing.xl),

                // 1. Achievements Section
                const WeightAchievementsCard(),
                
                const SizedBox(height: AppSpacing.xl),

                // 2. Current Stats
                CurrentWeightCard(
                  weight: weightData.weight,
                  height: weightData.height,
                  weightHistory: weightData.weightHistory,
                ),
                
                const SizedBox(height: AppSpacing.lg),

                BMIScaleCard(
                  currentBMI: weightData.height > 0 
                    ? weightData.weight / ((weightData.height / 100) * (weightData.height / 100))
                    : null,
                ),
                
                const SizedBox(height: AppSpacing.xl),

                // 3. Chart Section
                const WeightProgressChart(),
                
                const SizedBox(height: AppSpacing.xl),

                // 4. Action Section
                AddWeightForm(
                  onAddWeight: (weightValue) {
                    _saveWeight(context, ref, weightValue);
                  },
                ),
                
                const SizedBox(height: AppSpacing.xl),

                // 5. History Section
                if (weightData.weightHistory.isNotEmpty)
                  WeightHistoryCard(
                    weightHistory: weightData.weightHistory,
                    height: weightData.height,
                    onDelete: (index) {
                      _deleteWeight(context, ref, weightData.weightHistory[index].id);
                    },
                  ),
              ],
            ),
          ),
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => Center(child: Text('Lỗi: $error', style: const TextStyle(color: AppColors.black)),
          ),
        ),
      ),
    );
  }

  void _saveWeight( BuildContext context, WidgetRef ref, String weightValue,) async {
    try {
      final weight = double.tryParse(weightValue);
      if (weight == null) return;
      await ref.read(weightControllerProvider.notifier).addWeight(weight);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã lưu cân nặng')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }

  void _deleteWeight( BuildContext context, WidgetRef ref, int recordId,) async {
    try {
      await ref.read(weightControllerProvider.notifier).deleteWeight(recordId);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Đã xóa bản ghi')),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e')),
        );
      }
    }
  }
}
