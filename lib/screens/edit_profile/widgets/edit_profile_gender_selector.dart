import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class EditProfileGenderSelector extends StatelessWidget {
  final String? selectedGender;
  final Function(String) onGenderChanged;

  const EditProfileGenderSelector({
    super.key,
    required this.selectedGender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(Icons.wc_rounded, size: 18, color: AppColors.primary),
            SizedBox(width: 8),
            Text('Giới tính', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.black)),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            _GenderButton(
              label: 'Nam',
              value: 'male',
              isSelected: selectedGender == 'male',
              onTap: () => onGenderChanged('male'),
            ),
            const SizedBox(width: 12),
            _GenderButton(
              label: 'Nữ',
              value: 'female',
              isSelected: selectedGender == 'female',
              onTap: () => onGenderChanged('female'),
            ),
          ],
        ),
      ],
    );
  }
}

class _GenderButton extends StatelessWidget {
  final String label;
  final String value;
  final bool isSelected;
  final VoidCallback onTap;

  const _GenderButton({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? AppColors.primary : AppColors.bgLight,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: isSelected ? AppColors.primary : AppColors.cardBorder),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? AppColors.white : AppColors.grey,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
