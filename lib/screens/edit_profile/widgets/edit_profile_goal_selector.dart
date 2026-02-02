import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../utils/label_utils.dart';

class EditProfileGoalSelector extends StatelessWidget {
  final String? selectedGoal;
  final Function(String) onGoalChanged;

  const EditProfileGoalSelector({
    super.key,
    required this.selectedGoal,
    required this.onGoalChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.track_changes_rounded,
              size: 18,
              color: AppColors.primary,
            ),
            SizedBox(width: 8),
            Text(
              'Mục tiêu',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.black,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          decoration: const BoxDecoration(color: Colors.transparent),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _normalizeGoal(selectedGoal),
              isExpanded: true,
              icon: const Icon(
                Icons.keyboard_arrow_down_rounded,
                color: AppColors.grey,
              ),
              dropdownColor: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              items: ['lose', 'maintain', 'gain'].map((String value) {
                return DropdownMenuItem<String>(
                  value: value,
                  child: Text(
                    LabelUtils.getGoalLabel(value),
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: AppColors.black,
                    ),
                  ),
                );
              }).toList(),
              onChanged: (val) {
                if (val != null) onGoalChanged(val);
              },
            ),
          ),
        ),
      ],
    );
  }

  String _normalizeGoal(String? goal) {
    if (goal == null) return 'maintain';
    final normalized = goal.toLowerCase();
    if (normalized == 'lose' || normalized == 'lose_weight') return 'lose';
    if (normalized == 'gain' || normalized == 'gain_muscle') return 'gain';
    if (normalized == 'maintain') return 'maintain';
    return 'maintain'; // Default fallback
  }
}
