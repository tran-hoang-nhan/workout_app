import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class AuthInputField extends StatelessWidget {
  final String label;
  final IconData icon;
  final TextEditingController controller;
  final String placeholder;
  final TextInputType keyboardType;
  final Iterable<String>? autofillHints;

  const AuthInputField({
    super.key,
    required this.label,
    required this.icon,
    required this.controller,
    required this.placeholder,
    this.keyboardType = TextInputType.text,
    this.autofillHints,
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
        Container(
          decoration: BoxDecoration(
            color: AppColors.greyLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            autofillHints: autofillHints,
            style: const TextStyle(color: AppColors.black, fontSize: 15),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: AppColors.grey, fontSize: 15),
              prefixIcon: Icon(icon, color: AppColors.grey, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
