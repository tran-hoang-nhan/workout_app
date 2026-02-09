import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/health_provider.dart';
import '../../models/health_params.dart';

import '../health_form/health_form.dart';
import 'widgets/health_header.dart';
import 'widgets/health_alerts.dart';
import 'widgets/input_section.dart';
import 'widgets/bmi_card.dart';
import 'widgets/step_card.dart';
import 'widgets/water_card.dart';
import 'widgets/water_intake_card.dart';
import 'widgets/heart_rate_zones.dart';
import 'widgets/calorie_goals.dart';
import '../../providers/progress_user_provider.dart';
import '../../providers/app_state_provider.dart';
import '../../widgets/loading_animation.dart';
import '../../utils/app_error.dart';

class HealthScreen extends ConsumerStatefulWidget {
  const HealthScreen({super.key});

  @override
  ConsumerState<HealthScreen> createState() => _HealthScreenState();
}

class _HealthScreenState extends ConsumerState<HealthScreen> {
  late TextEditingController _weightInput;
  late TextEditingController _heightInput;

  @override
  void initState() {
    super.initState();
    _weightInput = TextEditingController();
    _heightInput = TextEditingController();
  }

  @override
  void dispose() {
    _weightInput.dispose();
    _heightInput.dispose();
    super.dispose();
  }

  void _updateControllers(HealthUpdateParams formState) {
    final newWeight = formState.weight.toStringAsFixed(0);
    final newHeight = formState.height.toStringAsFixed(0);

    if (_weightInput.text != newWeight) {
      _weightInput.text = newWeight;
    }
    if (_heightInput.text != newHeight) {
      _heightInput.text = newHeight;
    }
  }

  TextEditingController get weightInput => _weightInput;
  TextEditingController get heightInput => _heightInput;

  @override
  Widget build(BuildContext context) {
    final formState = ref.watch(healthFormProvider);
    final today = ref.watch(currentDateProvider);
    final todayProgressAsync = ref.watch(progressDailyProvider(today));

    final healthDataAsync = ref.watch(healthDataProvider);
    final calculations = ref.watch(healthCalculationsProvider);

    final goalCups = (formState.waterIntake / 250).ceil();
    final currentCups = todayProgressAsync.when(
      data: (progress) => (progress?.waterMl ?? 0) ~/ 250,
      loading: () => 0,
      error: (_, _) => 0,
    );

    final steps = todayProgressAsync.when(
      data: (progress) => progress?.steps ?? 0,
      loading: () => 0,
      error: (_, _) => 0,
    );

    ref.watch(syncHealthProfileProvider);
    _updateControllers(formState);

    final screenWidth = MediaQuery.of(context).size.width;
    final cardHeight = (screenWidth < 360) ? 190.0 : 220.0;

    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.lg).copyWith(bottom: 100),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              HealthHeader(onEditTap: _showEditModal),
              const SizedBox(height: AppSpacing.xl),

              // Health Alerts
              if (formState.injuries.isNotEmpty ||
                  formState.medicalConditions.isNotEmpty)
                HealthAlerts(formState: formState),
              if (formState.injuries.isNotEmpty ||
                  formState.medicalConditions.isNotEmpty)
                const SizedBox(height: AppSpacing.lg),

              // Input Section
              InputSection(
                formState: formState,
                weightInput: weightInput,
                heightInput: heightInput,
              ),
              const SizedBox(height: AppSpacing.lg),

              // BMI Card
              BMICard(calculations: calculations),
              const SizedBox(height: AppSpacing.md),

              // Steps & Water Row
              healthDataAsync.when(
                loading: () => SizedBox(
                  height: cardHeight,
                  child: const Center(
                    child: AppLoading(),
                  ), // Replaced CircularProgressIndicator with AppLoading
                ),
                error: (e, st) => Container(
                  height: cardHeight,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: AppColors.cardBorder.withValues(alpha: 0.5),
                    ),
                  ),
                  child: Center(
                    child: Text(
                      'Lỗi tải dữ liệu: ${e is AppError ? e.userMessage : e}',
                      style: const TextStyle(color: Colors.red, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
                data: (_) => Row(
                  children: [
                    StepCard(steps: steps, height: cardHeight),
                    const SizedBox(width: AppSpacing.md),
                    WaterCard(
                      currentCups: currentCups,
                      waterGoal: goalCups,
                      height: cardHeight,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Water Intake
              WaterIntakeCard(formState: formState),
              const SizedBox(height: AppSpacing.md),

              // Heart Rate Zones
              HeartRateZones(calculations: calculations),
              const SizedBox(height: AppSpacing.md),

              // Calorie Goals
              CalorieGoals(calculations: calculations),
            ],
          ),
        ),
      ),
    );
  }

  void _showEditModal() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _HealthEditModalContent(),
    );
  }
}

class _HealthEditModalContent extends ConsumerStatefulWidget {
  const _HealthEditModalContent();

  @override
  ConsumerState<_HealthEditModalContent> createState() =>
      _HealthEditModalContentState();
}

class _HealthEditModalContentState
    extends ConsumerState<_HealthEditModalContent> {
  late TextEditingController injuryController;
  late TextEditingController conditionController;
  late TextEditingController allergyController;

  @override
  void initState() {
    super.initState();
    injuryController = TextEditingController();
    conditionController = TextEditingController();
    allergyController = TextEditingController();
  }

  @override
  void dispose() {
    injuryController.dispose();
    conditionController.dispose();
    allergyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      maxChildSize: 0.95,
      minChildSize: 0.5,
      builder: (context, scrollController) => Container(
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: HealthFormUI(
          injuryController: injuryController,
          conditionController: conditionController,
          allergyController: allergyController,
          onClose: () => Navigator.pop(context),
          isSaving: false,
        ),
      ),
    );
  }
}
