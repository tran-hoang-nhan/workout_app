import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../../constants/app_constants.dart';

class HealthInputWidget extends StatelessWidget {
  final String label;
  final List<String> items;
  final TextEditingController controller;
  final VoidCallback onAdd;
  final Function(int) onRemove;
  final String placeholder;

  const HealthInputWidget({
    super.key,
    required this.label,
    required this.items,
    required this.controller,
    required this.onAdd,
    required this.onRemove,
    required this.placeholder,
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
        Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1F2937),
                  border: Border.all(color: Colors.grey.shade800),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: controller,
                  onSubmitted: (_) => onAdd(),
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: placeholder,
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(AppSpacing.md),
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            GestureDetector(
              onTap: onAdd,
              child: Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.orange.shade500,
                      Colors.red.shade500,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.add,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: items
                .asMap()
                .entries
                .map(
                  (entry) => Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1F2937),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.value,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 6),
                        GestureDetector(
                          onTap: () => onRemove(entry.key),
                          child: Icon(
                            Icons.close,
                            size: 16,
                            color: Colors.grey.shade500,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
                .toList(),
          ),
        ],
      ],
    );
  }
}
