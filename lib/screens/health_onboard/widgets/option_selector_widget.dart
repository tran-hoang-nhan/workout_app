import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';

class OptionSelectorWidget extends StatelessWidget {
  final String label;
  final List<Map<String, dynamic>> options;
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
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: AppSpacing.md),
          child: Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 12,
              letterSpacing: 1.2,
              color: AppColors.grey.withValues(alpha: 0.8),
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: options.length,
          separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.md),
          itemBuilder: (context, index) {
            final opt = options[index];
            final isSelected = selected == opt['value'];
            final icon = opt['icon'] as IconData?;
            final emoji = opt['emoji'] as String?;

            return GestureDetector(
              onTap: () => onSelected(opt['value']!),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.white : AppColors.white.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.cardBorder.withValues(alpha: 0.5),
                    width: 2,
                  ),
                  boxShadow: [
                    if (isSelected)
                      BoxShadow(
                        color: AppColors.primary.withValues(alpha: 0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 8),
                      )
                    else
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.02),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                  ],
                ),
                child: Row(
                  children: [
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isSelected 
                            ? AppColors.primary.withValues(alpha: 0.1) 
                            : AppColors.bgLight,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Center(
                        child: icon != null 
                            ? Icon(icon, color: isSelected ? AppColors.primary : AppColors.grey, size: 24)
                            : Text(emoji ?? '✨', style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            opt['label']!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isSelected ? AppColors.black : AppColors.black.withValues(alpha: 0.7),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            opt['desc']!,
                            style: TextStyle(
                              fontSize: 13,
                              color: AppColors.grey.withValues(alpha: 0.8),
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (isSelected)
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: AppColors.primary,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 16,
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
