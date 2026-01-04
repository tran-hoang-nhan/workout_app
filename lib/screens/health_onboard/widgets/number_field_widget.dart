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
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.value);
  }

  @override
  void didUpdateWidget(NumberFieldWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value && _controller.text != widget.value) {
      _controller.text = widget.value;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.md),
          child: Text(
            widget.label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              color: AppColors.grey.withValues(alpha: 0.8),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.cardBorder.withValues(alpha: 0.5), width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.03),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: TextField(
            controller: _controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onChanged: widget.onChanged,
            style: const TextStyle(
              color: AppColors.black,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 20),
              hintText: 'Nhập giá trị...',
              hintStyle: TextStyle(color: AppColors.grey.withValues(alpha: 0.5), fontWeight: FontWeight.normal),
              suffixIcon: Icon(Icons.edit_outlined, color: AppColors.primary.withValues(alpha: 0.5), size: 20),
            ),
          ),
        ),
      ],
    );
  }
}
