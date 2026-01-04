import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class GenderSelectorWidget extends StatelessWidget {
  final String selectedGender;
  final Function(String) onSelected;

  const GenderSelectorWidget({
    super.key,
    required this.selectedGender,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.md),
          child: Text(
            'GIỚI TÍNH'.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              color: AppColors.grey.withValues(alpha: 0.8),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Row(
          children: ['male', 'female', 'other'].map((g) {
            final labels = {'male': 'Nam', 'female': 'Nữ', 'other': 'Khác'};
            final icons = {
              'male': Icons.male_rounded, 
              'female': Icons.female_rounded, 
              'other': Icons.transgender_rounded
            };
            final isSelected = selectedGender == g;

            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(g),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                  margin: EdgeInsets.only(right: g != 'other' ? 8 : 0),
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.white : AppColors.white.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isSelected ? AppColors.primary : AppColors.cardBorder.withValues(alpha: 0.5),
                      width: 2,
                    ),
                    boxShadow: [
                      if (isSelected)
                        BoxShadow(
                          color: AppColors.primary.withValues(alpha: 0.2),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        icons[g],
                        color: isSelected ? AppColors.primary : AppColors.grey,
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        labels[g] ?? g,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? AppColors.black : AppColors.black.withValues(alpha: 0.6),
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }
}
