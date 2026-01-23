import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../providers/health_provider.dart';

class HealthEditForm extends StatefulWidget {
  final HealthFormState initialState;
  final Function(HealthFormState) onSave;
  final VoidCallback onCancel;

  const HealthEditForm({
    super.key,
    required this.initialState,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<HealthEditForm> createState() => _HealthEditFormState();
}

class _HealthEditFormState extends State<HealthEditForm> {
  late TextEditingController ageController;
  late TextEditingController weightController;
  late TextEditingController heightController;
  late String dietType;

  @override
  void initState() {
    super.initState();
    ageController = TextEditingController(text: widget.initialState.age.toString());
    weightController = TextEditingController(text: widget.initialState.weight.toString());
    heightController = TextEditingController(text: widget.initialState.height.toString());
    dietType = widget.initialState.dietType;
  }

  @override
  void dispose() {
    ageController.dispose();
    weightController.dispose();
    heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cập nhật thông tin',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: AppSpacing.lg),
          _buildField('Tuổi', ageController, TextInputType.number),
          const SizedBox(height: AppSpacing.md),
          _buildField('Cân nặng (kg)', weightController, TextInputType.number),
          const SizedBox(height: AppSpacing.md),
          _buildField('Chiều cao (cm)', heightController, TextInputType.number),
          const SizedBox(height: AppSpacing.md),
          const Text('Chế độ ăn', style: TextStyle(fontSize: 13, color: AppColors.grey)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            decoration: BoxDecoration(
              color: AppColors.bgLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: dietType,
                isExpanded: true,
                items: [
                  'normal', 'vegan', 'vegetarian', 'keto', 'paleo', 'low_carb'
                ].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(_mapDietType(value), style: const TextStyle(fontSize: 14)),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) setState(() => dietType = val);
                },
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Expanded(
                child: TextButton(
                  onPressed: widget.onCancel,
                  child: const Text('Hủy', style: TextStyle(color: AppColors.grey)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final newState = widget.initialState.copyWith(
                      age: int.tryParse(ageController.text) ?? widget.initialState.age,
                      weight: double.tryParse(weightController.text) ?? widget.initialState.weight,
                      height: double.tryParse(heightController.text) ?? widget.initialState.height,
                      dietType: dietType,
                    );
                    widget.onSave(newState);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Lưu thay đổi', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, TextInputType type) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 13, color: AppColors.grey)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: type,
          style: const TextStyle(fontSize: 14),
          decoration: InputDecoration(
            isDense: true,
            filled: true,
            fillColor: AppColors.bgLight,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.cardBorder),
            ),
          ),
        ),
      ],
    );
  }

  String _mapDietType(String type) {
    switch (type) {
      case 'normal': return 'Bình thường';
      case 'vegan': return 'Thuần chay';
      case 'vegetarian': return 'Ăn chay';
      case 'keto': return 'Keto';
      case 'paleo': return 'Paleo';
      case 'low_carb': return 'Low Carb';
      default: return type;
    }
  }
}
