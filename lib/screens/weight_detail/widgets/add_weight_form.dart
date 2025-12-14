import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class AddWeightForm extends StatefulWidget {
  final Function(String) onAddWeight;

  const AddWeightForm({
    super.key,
    required this.onAddWeight,
  });

  @override
  State<AddWeightForm> createState() => _AddWeightFormState();
}

class _AddWeightFormState extends State<AddWeightForm> {
  late TextEditingController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(25),
        border: Border.all(color: AppColors.cardBorder),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Thêm cân nặng mới',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.black)),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    hintText: 'Nhập cân nặng (kg)',
                    hintStyle: const TextStyle(
                        color: AppColors.grey),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(AppBorderRadius.md),
                      borderSide: BorderSide(
                          color: AppColors.cardBorder),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(20),
                      borderSide: const BorderSide(
                          color: AppColors.primary),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.md,
                        vertical: AppSpacing.md),
                  ),
                  style: const TextStyle(
                      color: AppColors.black, fontSize: 14),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              ElevatedButton(
                onPressed: () {
                  if (_controller.text.isNotEmpty) {
                    widget.onAddWeight(_controller.text);
                    _controller.clear();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF97316),
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                      vertical: AppSpacing.md),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.add, size: 20),
                    SizedBox(width: AppSpacing.sm),
                    Text('Thêm',
                        style: TextStyle(fontSize: 14)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
