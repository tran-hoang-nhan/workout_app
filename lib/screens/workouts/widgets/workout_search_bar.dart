import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class WorkoutSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const WorkoutSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F7FA),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.transparent),
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm...',
          hintStyle: TextStyle(
            color: AppColors.grey.withValues(alpha: 0.5),
            fontSize: 15,
          ),
          prefixIcon: Icon(
            Icons.search,
            color: AppColors.grey.withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 16),
        ),
      ),
    );
  }
}
