import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/health_provider.dart';
import 'health_form.dart';
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
import '../../utils/ui_utils.dart';
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

  void _updateControllers(HealthFormState formState) {
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
    // Watch current date provider to rebuild on day change
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
    final formState = ref.watch(healthFormProvider);

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
          age: formState.age,
          weight: formState.weight,
          height: formState.height,
          gender: formState.gender,
          injuries: formState.injuries,
          medicalConditions: formState.medicalConditions,
          activityLevel: formState.activityLevel,
          waterIntake: formState.waterIntake.toInt(),
          dietType: formState.dietType,
          allergies: formState.allergies,
          waterReminderEnabled: formState.waterReminderEnabled,
          waterReminderInterval: formState.waterReminderInterval,
          wakeTime: formState.wakeTime,
          sleepTime: formState.sleepTime,
          injuryController: injuryController,
          conditionController: conditionController,
          allergyController: allergyController,
          isSaving: false,
          onAgeChanged: (value) => ref.read(healthFormProvider.notifier).setAge(value),
          onWeightChanged: (value) => ref.read(healthFormProvider.notifier).setWeight(value),
          onHeightChanged: (value) => ref.read(healthFormProvider.notifier).setHeight(value),
          onGenderChanged: (value) => ref.read(healthFormProvider.notifier).setGender(value),
          onAddInjury: () {
            if (injuryController.text.trim().isNotEmpty) {
              ref.read(healthFormProvider.notifier).addInjury(injuryController.text.trim());
              injuryController.clear();
            }
          },
          onRemoveInjury: (index) =>
              ref.read(healthFormProvider.notifier).removeInjury(index),
          onAddCondition: () {
            if (conditionController.text.trim().isNotEmpty) {
              ref.read(healthFormProvider.notifier).addCondition(conditionController.text.trim());
              conditionController.clear();
            }
          },
          onRemoveCondition: (index) =>
              ref.read(healthFormProvider.notifier).removeCondition(index),
          onAddAllergy: () {
            if (allergyController.text.trim().isNotEmpty) {
              ref.read(healthFormProvider.notifier).addAllergy(allergyController.text.trim());
              allergyController.clear();
            }
          },
          onRemoveAllergy: (index) => ref.read(healthFormProvider.notifier).removeAllergy(index),
          onActivityLevelChanged: (value) => ref.read(healthFormProvider.notifier).setActivityLevel(value),
          onWaterIntakeChanged: (value) => ref.read(healthFormProvider.notifier).setWaterIntake(value.toDouble()),
          onDietTypeChanged: (value) => ref.read(healthFormProvider.notifier).setDietType(value),
          onWaterReminderEnabledChanged: (value) => ref.read(healthFormProvider.notifier).setWaterReminderEnabled(value),
          onWaterReminderIntervalChanged: (value) => ref.read(healthFormProvider.notifier).setWaterReminderInterval(value),
          onWakeTimeChanged: (value) => ref.read(healthFormProvider.notifier).setWakeTime(value),
          onSleepTimeChanged: (value) => ref.read(healthFormProvider.notifier).setSleepTime(value),
          onClose: () => Navigator.pop(context),
          onSave: () async {
            try {
              await ref.read(
                saveHealthProfileProvider(
                  HealthProfileSaveParams(
                    height: formState.height,
                    gender: null,
                  ),
                ).future,
              );

              if (context.mounted) {
                context.showSuccess('Đã lưu thông tin sức khỏe thành công!');
                Navigator.pop(context);
              }
            } catch (e) {
              if (context.mounted) {
                context.showError(e);
              }
            }
          },
        ),
      ),
    );
  }
}
