import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class NumberFieldWidget extends StatefulWidget {
  final String label;
  final String value;
  final Function(String) onChanged;
  final int min;
  final int? max;
  final double? step;

  const NumberFieldWidget({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    required this.min,
    this.max,
    this.step,
  });

  @override
  State<NumberFieldWidget> createState() => _NumberFieldWidgetState();
}

class _NumberFieldWidgetState extends State<NumberFieldWidget> {
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
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
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: widget.onChanged,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.all(AppSpacing.md),
              hintText: widget.value,
              hintStyle: const TextStyle(color: AppColors.grey),
            ),
          ),
        ),
      ],
    );
  }
}
