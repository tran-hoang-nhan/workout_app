import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class AuthPasswordField extends StatefulWidget {
  final TextEditingController controller;
  final String label;

  const AuthPasswordField({
    super.key,
    required this.controller,
    this.label = 'Mật khẩu',
  });

  @override
  State<AuthPasswordField> createState() => _AuthPasswordFieldState();
}

class _AuthPasswordFieldState extends State<AuthPasswordField> {
  bool showPassword = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
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
            controller: widget.controller,
            obscureText: !showPassword,
            autofillHints: const [AutofillHints.password],
            style: const TextStyle(color: AppColors.black, fontSize: 15),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(color: AppColors.grey, fontSize: 15),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.grey,
                size: 20,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() => showPassword = !showPassword);
                },
                child: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.grey,
                  size: 20,
                ),
              ),
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
