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
        Text(
          'Giới tính',
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: ['male', 'female', 'other'].map((g) {
            final labels = {'male': 'Nam', 'female': 'Nữ', 'other': 'Khác'};
            final isSelected = selectedGender == g;

            return Expanded(
              child: GestureDetector(
                onTap: () => onSelected(g),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  margin: EdgeInsets.only(right: g != 'other' ? 8 : 0),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.orange.withValues(alpha: 0.1)
                        : const Color(0xFF1F2937),
                    border: Border.all(
                      color: isSelected
                          ? Colors.orange.shade500
                          : Colors.grey.shade800,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    labels[g] ?? g,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color:
                          isSelected ? Colors.orange.shade500 : Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
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
