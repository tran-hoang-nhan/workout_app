import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/health_provider.dart';
import 'health_form.dart';
import 'widgets/health_header.dart';
import 'widgets/health_alerts.dart';
import 'widgets/input_section.dart';
import 'widgets/bmi_card.dart';
import 'widgets/steps_water_cards.dart';
import 'widgets/water_intake_card.dart';
import 'widgets/heart_rate_zones.dart';
import 'widgets/calorie_goals.dart';

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
    // Update controllers từ formState
    // Selection position sẽ được giữ nếu text không thay đổi
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
    final calculations = ref.watch(healthCalculationsProvider);
    ref.watch(syncHealthProfileProvider);
    _updateControllers(formState);

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
              if (formState.injuries.isNotEmpty || formState.medicalConditions.isNotEmpty)
                HealthAlerts(formState: formState),
              if (formState.injuries.isNotEmpty || formState.medicalConditions.isNotEmpty)
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

              // Steps & Water
              const StepsWaterCards(),
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
  ConsumerState<_HealthEditModalContent> createState() => _HealthEditModalContentState();
}

class _HealthEditModalContentState extends ConsumerState<_HealthEditModalContent> {
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
          color: Color(0xFF0A0E27),
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
          sleepHours: formState.sleepHours.toDouble(),
          waterIntake: formState.waterIntake.toInt(),
          dietType: formState.dietType,
          allergies: formState.allergies,
          waterReminderEnabled: formState.waterReminderEnabled,
          waterReminderInterval: formState.waterReminderInterval,
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
          onRemoveInjury: (index) => ref.read(healthFormProvider.notifier).removeInjury(index),
          onAddCondition: () {
            if (conditionController.text.trim().isNotEmpty) {
              ref.read(healthFormProvider.notifier).addCondition(conditionController.text.trim());
              conditionController.clear();
            }
          },
          onRemoveCondition: (index) => ref.read(healthFormProvider.notifier).removeCondition(index),
          onAddAllergy: () {
            if (allergyController.text.trim().isNotEmpty) {
              ref.read(healthFormProvider.notifier).addAllergy(allergyController.text.trim());
              allergyController.clear();
            }
          },
          onRemoveAllergy: (index) => ref.read(healthFormProvider.notifier).removeAllergy(index),
          onActivityLevelChanged: (value) => ref.read(healthFormProvider.notifier).setActivityLevel(value),
          onSleepHoursChanged: (value) => ref.read(healthFormProvider.notifier).setSleepHours(value),
          onWaterIntakeChanged: (value) => ref.read(healthFormProvider.notifier).setWaterIntake(value.toDouble()),
          onDietTypeChanged: (value) => ref.read(healthFormProvider.notifier).setDietType(value),
          onWaterReminderEnabledChanged: (value) => ref.read(healthFormProvider.notifier).setWaterReminderEnabled(value),
          onWaterReminderIntervalChanged: (value) => ref.read(healthFormProvider.notifier).setWaterReminderInterval(value),
          onClose: () => Navigator.pop(context),
          onSave: () async {
            try {
              await ref.read(saveHealthProfileProvider(HealthProfileSaveParams(
                height: formState.height,
                gender: null,
              )).future);

              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Đã lưu thông tin sức khỏe thành công!')),
                );
                Navigator.pop(context);
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Lỗi: ${e.toString()}')),
                );
              }
            }
          },
        ),
      ),
    );
  }
}

