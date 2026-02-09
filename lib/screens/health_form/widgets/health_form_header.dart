import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';

class HealthFormHeader extends ConsumerWidget {
  final VoidCallback? onClose;

  const HealthFormHeader({super.key, this.onClose});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Hồ sơ sức khỏe',
              style: TextStyle(
                fontSize: AppFontSize.xxxl,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
              ),
            ),
            if (onClose != null)
              IconButton(
                onPressed: onClose,
                icon: const Icon(Icons.close, color: AppColors.black),
                style: IconButton.styleFrom(
                  backgroundColor: AppColors.greyLight,
                  padding: const EdgeInsets.all(AppSpacing.sm),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        const Text(
          'Vui lòng điền thông tin để chúng tôi tư vấn tốt hơn',
          style: TextStyle(fontSize: AppFontSize.md, color: AppColors.grey),
        ),
        const SizedBox(height: AppSpacing.lg),

        // Alert Banner
        Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.05),
            border: Border.all(color: AppColors.primary.withValues(alpha: 0.2)),
            borderRadius: BorderRadius.circular(AppBorderRadius.lg),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Thông tin quan trọng',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.bold,
                        fontSize: AppFontSize.sm,
                      ),
                    ),
                    SizedBox(height: AppSpacing.xs),
                    Text(
                      'Thông tin này giúp chúng tôi gợi ý bài tập phù hợp và an toàn cho bạn',
                      style: TextStyle(
                        color: AppColors.greyDark,
                        fontSize: AppFontSize.sm,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
