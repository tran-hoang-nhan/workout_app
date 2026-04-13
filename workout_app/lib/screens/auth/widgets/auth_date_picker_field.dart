import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class AuthDatePickerField extends StatelessWidget {
  final String label;
  final IconData icon;
  final String value;
  final String placeholder;
  final VoidCallback onTap;

  const AuthDatePickerField({
    super.key,
    required this.label,
    required this.icon,
    required this.value,
    required this.placeholder,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.greyLight.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.cardBorder),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.md,
              vertical: 16,
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.grey, size: 20),
                const SizedBox(width: AppSpacing.md),
                Text(
                  value.isEmpty ? placeholder : value,
                  style: TextStyle(
                    color: value.isEmpty ? AppColors.grey : AppColors.black,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
