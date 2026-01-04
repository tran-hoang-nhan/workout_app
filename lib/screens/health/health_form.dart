import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// UI-only form component. All data handling via callbacks.
/// Logic xử lý dữ liệu ở parent widget hoặc service/provider
class HealthFormUI extends StatelessWidget {
  // Input values từ parent
  final int age;
  final double weight;
  final double height;
  final String gender;
  final List<String> injuries;
  final List<String> medicalConditions;
  final String activityLevel;
  final double sleepHours;
  final int waterIntake;
  final String dietType;
  final List<String> allergies;
  final bool waterReminderEnabled;
  final int waterReminderInterval;


  // Controllers
  final TextEditingController injuryController;
  final TextEditingController conditionController;
  final TextEditingController allergyController;

  // Callbacks - Logic xử lý ở parent
  final ValueChanged<int> onAgeChanged;
  final ValueChanged<double> onWeightChanged;
  final ValueChanged<double> onHeightChanged;
  final ValueChanged<String> onGenderChanged;
  final VoidCallback onAddInjury;
  final ValueChanged<int> onRemoveInjury;
  final VoidCallback onAddCondition;
  final ValueChanged<int> onRemoveCondition;
  final VoidCallback onAddAllergy;
  final ValueChanged<int> onRemoveAllergy;
  final ValueChanged<String> onActivityLevelChanged;
  final ValueChanged<double> onSleepHoursChanged;
  final ValueChanged<int> onWaterIntakeChanged;
  final ValueChanged<String> onDietTypeChanged;
  final ValueChanged<bool> onWaterReminderEnabledChanged;
  final ValueChanged<int> onWaterReminderIntervalChanged;
  final VoidCallback onSave;
  final VoidCallback? onClose;


  final bool isSaving;

  const HealthFormUI({
    super.key,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.injuries,
    required this.medicalConditions,
    required this.activityLevel,
    required this.sleepHours,
    required this.waterIntake,
    required this.dietType,
    required this.allergies,
    required this.waterReminderEnabled,
    required this.waterReminderInterval,
    required this.injuryController,
    required this.conditionController,
    required this.allergyController,
    required this.onAgeChanged,
    required this.onWeightChanged,
    required this.onHeightChanged,
    required this.onGenderChanged,
    required this.onAddInjury,
    required this.onRemoveInjury,
    required this.onAddCondition,
    required this.onRemoveCondition,
    required this.onAddAllergy,
    required this.onRemoveAllergy,
    required this.onActivityLevelChanged,
    required this.onSleepHoursChanged,
    required this.onWaterIntakeChanged,
    required this.onDietTypeChanged,
    required this.onWaterReminderEnabledChanged,
    required this.onWaterReminderIntervalChanged,
    required this.onSave,
    this.onClose,
    this.isSaving = false,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(AppSpacing.lg).copyWith(bottom: 100),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Hồ sơ sức khỏe',
                style: TextStyle(
                  fontSize: AppFontSize.xxxl,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              if (onClose != null)
                IconButton(
                  onPressed: onClose,
                  icon: const Icon(Icons.close, color: AppColors.black),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.greyLight,
                    padding: const EdgeInsets.all(AppSpacing.sm),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          const Text(
            'Vui lòng điền thông tin để chúng tôi tư vấn tốt hơn',
            style: TextStyle(
              fontSize: AppFontSize.md,
              color: AppColors.grey,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Alert Banner
          Container(
            padding: const EdgeInsets.all(AppSpacing.md),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(AppBorderRadius.lg),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Icon(Icons.info_outline, color: AppColors.primary, size: 20),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text(
                        'Thông tin quan trọng',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.bold,
                          fontSize: AppFontSize.sm,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Thông tin này giúp chúng tôi gợi ý bài tập phù hợp và an toàn cho bạn',
                        style: TextStyle(
                          color: AppColors.greyDark,
                          fontSize: AppFontSize.sm,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // Age
          _buildInputField(
            'Tuổi',
            age.toString(),
            (value) => onAgeChanged(int.tryParse(value) ?? age),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Weight
          _buildInputField(
            'Cân nặng (kg)',
            weight.toString(),
            (value) => onWeightChanged(double.tryParse(value) ?? weight),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Height
          _buildInputField(
            'Chiều cao (cm)',
            height.toString(),
            (value) => onHeightChanged(double.tryParse(value) ?? height),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Gender dropdown
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Giới tính',
                style: const TextStyle(
                  fontSize: AppFontSize.lg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                  border: Border.all(color: AppColors.cardBorder),
                  borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: gender,
                      isExpanded: true,
                      icon: const Icon(Icons.keyboard_arrow_down, color: AppColors.grey),
                      items: const [
                        DropdownMenuItem(value: 'male', child: Text('Nam', style: TextStyle(color: AppColors.black))),
                        DropdownMenuItem(value: 'female', child: Text('Nữ', style: TextStyle(color: AppColors.black))),
                        DropdownMenuItem(value: 'other', child: Text('Khác', style: TextStyle(color: AppColors.black))),
                      ],
                      onChanged: (value) {
                        if (value != null) onGenderChanged(value);
                      },
                      dropdownColor: AppColors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // Injuries
          _buildListField(
            'Chấn thương hiện tại',
            injuries,
            injuryController,
            'VD: Đau đầu gối trái, đau lưng dưới...',
            onAddInjury,
            onRemoveInjury,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Medical Conditions
          _buildListField(
            'Tình trạng sức khỏe',
            medicalConditions,
            conditionController,
            'VD: Hen suyễn, tiểu đường, huyết áp cao...',
            onAddCondition,
            onRemoveCondition,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Activity Level
          _buildActivityLevelField(context),
          const SizedBox(height: AppSpacing.lg),

          // Sleep Hours
          _buildInputField(
            'Giấc ngủ trung bình (giờ/ngày)',
            sleepHours.toString(),
            (value) => onSleepHoursChanged(double.tryParse(value) ?? sleepHours),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: AppSpacing.lg),

          // Water Intake
          _buildWaterIntakeField(),
          const SizedBox(height: AppSpacing.lg),

          // Water Reminder
          _buildWaterReminderField(),
          const SizedBox(height: AppSpacing.lg),

          // Diet Type
          _buildDietTypeField(),
          const SizedBox(height: AppSpacing.lg),

          // Allergies
          _buildListField(
            'Dị ứng thực phẩm',
            allergies,
            allergyController,
            'VD: Đậu phộng, hải sản, sữa...',
            onAddAllergy,
            onRemoveAllergy,
          ),
          const SizedBox(height: AppSpacing.xl),

          // Save Button
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isSaving ? null : onSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                disabledBackgroundColor: AppColors.greyLight,
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                ),
                elevation: 4,
                shadowColor: AppColors.primary.withValues(alpha: 0.4),
              ),
              child: Text(
                isSaving ? 'Đang lưu...' : 'Lưu Hồ Sơ',
                style: const TextStyle(
                  fontSize: AppFontSize.lg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInputField(
    String label,
    String value,
    ValueChanged<String> onChanged, {
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppFontSize.lg,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            key: ValueKey(value),
            initialValue: value,
            onChanged: onChanged,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.black),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: AppColors.greyLight.withValues(alpha: 0.3),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListField(
    String label,
    List<String> items,
    TextEditingController controller,
    String placeholder,
    VoidCallback onAdd,
    ValueChanged<int> onRemove,
  ) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: AppFontSize.lg,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onAdd(),
                  style: const TextStyle(color: AppColors.black),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: const TextStyle(color: AppColors.grey),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      borderSide: const BorderSide(color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppBorderRadius.md),
                      borderSide: const BorderSide(color: AppColors.primary),
                    ),
                    filled: true,
                    fillColor: AppColors.greyLight.withValues(alpha: 0.3),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.md,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              ElevatedButton(
                onPressed: onAdd,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.lg,
                    vertical: AppSpacing.md,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                  ),
                ),
                child: const Text(
                  'Thêm',
                  style: TextStyle(
                    color: AppColors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (items.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: [
                ...items.asMap().entries.map((entry) {
                  final index = entry.key;
                  final item = entry.value;
                  return Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                      border: Border.all(color: AppColors.cardBorder),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          item,
                          style: const TextStyle(
                            color: AppColors.black,
                            fontSize: AppFontSize.sm,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: AppSpacing.sm),
                        GestureDetector(
                          onTap: () => onRemove(index),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.grey,
                            size: 16,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ],
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Chưa có gì được thêm',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: AppFontSize.sm,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActivityLevelField(BuildContext context) {
    final levels = [
      ('sedentary', 'Ít vận động', 'Ít hoặc không tập luyện'),
      ('lightly_active', 'Nhẹ nhàng', '1-3 ngày/tuần'),
      ('moderately_active', 'Trung bình', '3-5 ngày/tuần'),
      ('very_active', 'Rất tích cực', '6-7 ngày/tuần'),
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mức độ vận động',
            style: TextStyle(
              fontSize: AppFontSize.lg,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          ...levels.map(((level) {
            final value = level.$1;
            final label = level.$2;
            final desc = level.$3;
            final isSelected = activityLevel == value;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: GestureDetector(
                onTap: () => onActivityLevelChanged(value),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.primary.withValues(alpha: 0.05) : AppColors.white,
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.cardBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                    borderRadius: BorderRadius.circular(AppBorderRadius.md),
                    boxShadow: isSelected ? [
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      )
                    ] : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              label,
                              style: TextStyle(
                                color: isSelected ? AppColors.primary : AppColors.black,
                                fontWeight: FontWeight.bold,
                                fontSize: AppFontSize.md,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            Text(
                              desc,
                              style: TextStyle(
                                color: AppColors.grey,
                                fontSize: AppFontSize.sm,
                                fontWeight: isSelected ? FontWeight.w500 : FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (isSelected)
                         Icon(
                          Icons.check_circle,
                          color: AppColors.primary,
                          size: 24,
                        )
                      else
                        const Icon(
                          Icons.circle_outlined,
                          color: AppColors.cardBorder,
                          size: 24,
                        ),
                    ],
                  ),
                ),
              ),
            );
          })),
        ],
      ),
    );
  }

  Widget _buildWaterIntakeField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mục tiêu uống nước (ml/ngày)',
            style: TextStyle(
              fontSize: AppFontSize.lg,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          TextFormField(
            key: const ValueKey('waterIntake'),
            initialValue: waterIntake.toString(),
            onChanged: (value) => onWaterIntakeChanged(int.tryParse(value) ?? waterIntake),
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.black),
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                borderSide: const BorderSide(color: AppColors.cardBorder),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppBorderRadius.md),
                borderSide: const BorderSide(color: AppColors.primary),
              ),
              filled: true,
              fillColor: AppColors.greyLight.withValues(alpha: 0.3),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.md,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '≈ ${(waterIntake / 250).round()} ly nước',
            style: const TextStyle(
              color: AppColors.grey,
              fontSize: AppFontSize.sm,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterReminderField() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Nhắc nhở uống nước',
                style: TextStyle(
                  fontSize: AppFontSize.lg,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black,
                ),
              ),
              Switch(
                value: waterReminderEnabled,
                onChanged: onWaterReminderEnabledChanged,
                activeThumbColor: AppColors.white,
                activeTrackColor: AppColors.primary,
                inactiveThumbColor: AppColors.grey,
                inactiveTrackColor: AppColors.greyLight,
              ),
            ],
          ),
          if (waterReminderEnabled) ...[
            const SizedBox(height: AppSpacing.md),
            const Text(
              'Khoảng cách nhắc nhở (giờ)',
              style: TextStyle(
                color: AppColors.grey,
                fontSize: AppFontSize.sm,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [1, 2, 3, 4].map((hours) {
                final isSelected = waterReminderInterval == hours;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: ChoiceChip(
                    label: Text('$hours giờ'),
                    selected: isSelected,
                    onSelected: (selected) {
                      if (selected) onWaterReminderIntervalChanged(hours);
                    },
                    selectedColor: AppColors.primary,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.black,
                      fontSize: 12,
                    ),
                    backgroundColor: AppColors.white,
                    side: BorderSide(
                      color: isSelected ? AppColors.primary : AppColors.cardBorder,
                    ),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDietTypeField() {

    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        border: Border.all(color: AppColors.cardBorder),
        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
      ),
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chế độ ăn uống',
            style: TextStyle(
              fontSize: AppFontSize.lg,
              fontWeight: FontWeight.bold,
              color: AppColors.black,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            decoration: BoxDecoration(
              color: AppColors.white,
              border: Border.all(color: AppColors.cardBorder),
              borderRadius: BorderRadius.circular(AppBorderRadius.md),
            ),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: dietType,
                onChanged: (value) => onDietTypeChanged(value ?? 'normal'),
                items: [
                  ('normal', 'Bình thường'),
                  ('vegan', 'Thuần chay (Vegan)'),
                  ('vegetarian', 'Chay (Vegetarian)'),
                  ('keto', 'Keto'),
                  ('paleo', 'Paleo'),
                  ('low_carb', 'Low Carb'),
                  ('halal', 'Halal'),
                ]
                    .map((item) => DropdownMenuItem(
                          value: item.$1,
                          child: Text(item.$2, style: const TextStyle(color: AppColors.black)),
                        ))
                    .toList(),
                style: const TextStyle(color: AppColors.black),
                icon: const Icon(Icons.arrow_drop_down, color: AppColors.grey),
                dropdownColor: AppColors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
