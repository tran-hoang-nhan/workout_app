import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class OptionSelectorWidget extends StatelessWidget {
  final String label;
  final List<Map<String, String>> options;
  final String selected;
  final Function(String) onSelected;

  const OptionSelectorWidget({
    super.key,
    required this.label,
    required this.options,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
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
        Column(
          children: options.map((opt) {
            final isSelected = selected == opt['value'];
            return Column(
              children: [
                GestureDetector(
                  onTap: () => onSelected(opt['value']!),
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
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
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                opt['label']!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                opt['desc']!,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey.shade500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (isSelected)
                          Icon(
                            Icons.check_circle,
                            color: Colors.orange.shade500,
                          ),
                      ],
                    ),
                  ),
                ),
                if (opt != options.last)
                  const SizedBox(height: AppSpacing.md),
              ],
            );
          }).toList(),
        ),
      ],
    );
  }
}
