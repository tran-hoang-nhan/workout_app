import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../constants/app_constants.dart';
import '../../providers/health_provider.dart';
import 'widgets/index.dart';

class HealthOnboardingScreen extends ConsumerStatefulWidget {
  final Future<void> Function() onComplete;

  const HealthOnboardingScreen({
    super.key,
    required this.onComplete,
  });

  @override
  ConsumerState<HealthOnboardingScreen> createState() =>
      _HealthOnboardingScreenState();
}

class _HealthOnboardingScreenState
    extends ConsumerState<HealthOnboardingScreen> {
  int currentStep = 1;
  final totalSteps = 4;

  // Step 1: Basic Info
  int age = 25;
  double weight = 65;
  double height = 170;
  String gender = 'male';

  // Step 2: Activity & Goals
  String activityLevel = 'Trung bình';
  String goal = 'Duy trì';

  // Step 3: Lifestyle
  String dietType = 'normal';
  int sleepHours = 7;
  int waterIntake = 2000;

  // Step 4: Health Conditions (simple text input)
  String injuries = '';
  String medicalConditions = '';
  String allergies = '';

  bool isSaving = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header
              HeaderWidget(currentStep: currentStep, totalSteps: totalSteps),
              // Progress Bar
              ProgressBarWidget(currentStep: currentStep, totalSteps: totalSteps),
              // Content
              Padding(
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    StepTitleWidget(currentStep: currentStep),
                    const SizedBox(height: AppSpacing.lg),
                    _buildStepContent(),
                    const SizedBox(height: AppSpacing.lg),
                    NavigationButtonsWidget(
                      currentStep: currentStep,
                      totalSteps: totalSteps,
                      isSaving: isSaving,
                      onBack: () => setState(() => currentStep--),
                      onNext: currentStep < totalSteps ? _handleNext : _handleComplete,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (currentStep) {
      case 1:
        return _buildStep1();
      case 2:
        return _buildStep2();
      case 3:
        return _buildStep3();
      case 4:
        return _buildStep4();
      default:
        return const SizedBox();
    }
  }

  Widget _buildStep1() {
    return Column(
      children: [
        NumberFieldWidget(
          label: 'Tuổi của bạn',
          value: age.toString(),
          onChanged: (val) => setState(() => age = int.tryParse(val) ?? age),
          min: 1,
          max: 120,
        ),
        const SizedBox(height: AppSpacing.lg),
        NumberFieldWidget(
          label: 'Cân nặng (kg)',
          value: weight.toString(),
          onChanged: (val) =>
              setState(() => weight = double.tryParse(val) ?? weight),
          min: 1,
          step: 0.1,
        ),
        const SizedBox(height: AppSpacing.lg),
        NumberFieldWidget(
          label: 'Chiều cao (cm)',
          value: height.toString(),
          onChanged: (val) =>
              setState(() => height = double.tryParse(val) ?? height),
          min: 1,
          step: 0.1,
        ),
        const SizedBox(height: AppSpacing.lg),
        GenderSelectorWidget(
          selectedGender: gender,
          onSelected: (val) => setState(() => gender = val),
        ),
      ],
    );
  }

  Widget _buildStep2() {
    return Column(
      children: [
        OptionSelectorWidget(
          label: 'Mức độ vận động',
          options: [
            {
              'value': 'Ít vận động',
              'label': 'Ít vận động',
              'desc': 'Ít hoặc không tập luyện',
              'icon': Icons.weekend_outlined,
            },
            {
              'value': 'Nhẹ nhàng',
              'label': 'Nhẹ nhàng',
              'desc': '1-3 ngày/tuần',
              'icon': Icons.directions_run_outlined,
            },
            {
              'value': 'Trung bình',
              'label': 'Trung bình',
              'desc': '3-5 ngày/tuần',
              'icon': Icons.fitness_center_outlined,
            },
            {
              'value': 'Rất tích cực',
              'label': 'Rất tích cực',
              'desc': '6-7 ngày/tuần',
              'icon': Icons.bolt_rounded,
            },
          ],
          selected: activityLevel,
          onSelected: (val) => setState(() => activityLevel = val),
        ),
        const SizedBox(height: AppSpacing.xl),
        OptionSelectorWidget(
          label: 'Mục tiêu của bạn',
          options: [
            {
              'value': 'Giảm cân',
              'label': 'Giảm cân',
              'desc': 'Giảm mỡ và cải thiện vóc dáng',
              'icon': Icons.trending_down_rounded,
            },
            {
              'value': 'Duy trì',
              'label': 'Duy trì',
              'desc': 'Giữ vóc dáng hiện tại',
              'icon': Icons.balance_rounded,
            },
            {
              'value': 'Tăng cơ',
              'label': 'Tăng cơ',
              'desc': 'Xây dựng cơ bắp',
              'icon': Icons.fitness_center,
            },
          ],
          selected: goal,
          onSelected: (val) => setState(() => goal = val),
        ),
      ],
    );
  }

  Widget _buildStep3() {
    return Column(
      children: [
        DropdownFieldWidget(
          label: 'Chế độ ăn uống',
          value: dietType,
          items: [
            'normal',
            'vegan',
            'vegetarian',
            'keto',
            'paleo',
            'low_carb',
            'halal'
          ],
          onChanged: (val) => setState(() => dietType = val ?? dietType),
        ),
        const SizedBox(height: AppSpacing.lg),
        SliderFieldWidget(
          label: 'Giấc ngủ trung bình (giờ/ngày)',
          value: sleepHours.toDouble(),
          min: 4,
          max: 12,
          divisions: 8,
          onChanged: (val) => setState(() => sleepHours = val.round()),
        ),
        const SizedBox(height: AppSpacing.lg),
        SliderFieldWidget(
          label: 'Mục tiêu uống nước (ml/ngày)',
          value: waterIntake.toDouble(),
          min: 1000,
          max: 4000,
          divisions: 30,
          onChanged: (val) => setState(() => waterIntake = val.round()),
          suffix: 'ml',
        ),
      ],
    );
  }

  Widget _buildStep4() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primaryLight.withValues(alpha: 0.1),
            border: Border.all(
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              const Text(
                '💡',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Text(
                  'Bạn có thể bỏ qua bước này và hoàn thành sau',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.grey,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildTextField(
          label: 'Chấn thương hiện tại',
          value: injuries,
          onChanged: (val) => setState(() => injuries = val),
          placeholder: 'VD: Đau đầu gối trái',
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildTextField(
          label: 'Tình trạng sức khỏe',
          value: medicalConditions,
          onChanged: (val) => setState(() => medicalConditions = val),
          placeholder: 'VD: Hen suyễn, tiểu đường',
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildTextField(
          label: 'Dị ứng thực phẩm',
          value: allergies,
          onChanged: (val) => setState(() => allergies = val),
          placeholder: 'VD: Đậu phộng, hải sản',
        ),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required String value,
    required Function(String) onChanged,
    required String placeholder,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.white,
            border: Border.all(color: AppColors.cardBorder),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: TextField(
            controller: TextEditingController(text: value)..selection = TextSelection.collapsed(offset: value.length),
            onChanged: onChanged,
            style: const TextStyle(color: AppColors.black),
            maxLines: 2,
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: TextStyle(color: Colors.grey.shade600),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
            ),
          ),
        ),
      ],
    );
  }

  void _handleNext() {
    if (currentStep < totalSteps) {
      setState(() => currentStep++);
    }
  }

  Future<void> _handleComplete() async {
    setState(() => isSaving = true);
    try {
      final userId = Supabase.instance.client.auth.currentUser?.id;
      if (userId == null) return;
      await ref.read(healthFormProvider.notifier).saveHealthOnboarding(
        userId: userId, age: age, weight: weight, height: height, gender: gender,
        activityLevel: activityLevel, goal: goal, 
        dietType: dietType, sleepHours: sleepHours, waterIntake: waterIntake,
        injuries: injuries, medicalConditions: medicalConditions,allergies: allergies,
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Hoàn thành thông tin sức khỏe!')));
        await widget.onComplete();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    } finally {
      if (mounted) setState(() => isSaving = false);
    }
  }  
}
