import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class DropdownFieldWidget extends StatelessWidget {
  final String label;
  final String value;
  final List<String> items;
  final Function(String?) onChanged;

  const DropdownFieldWidget({
    super.key,
    required this.label,
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final labels = {
      'normal': 'Bình thường',
      'vegan': 'Thuần chay (Vegan)',
      'vegetarian': 'Chay (Vegetarian)',
      'keto': 'Keto',
      'paleo': 'Paleo',
      'low_carb': 'Low Carb',
      'halal': 'Halal',
    };

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFF1F2937),
            border: Border.all(color: Colors.grey.shade800),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButton<String>(
            value: value,
            isExpanded: true,
            underline: const SizedBox(),
            dropdownColor: const Color(0xFF1F2937),
            items: items
                .map(
                  (item) => DropdownMenuItem(
                    value: item,
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Text(
                        labels[item] ?? item,
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                )
                .toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }
}
