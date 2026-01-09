import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../widgets/loading_animation.dart';

class EditProfileAvatar extends StatelessWidget {
  final String displayAvatarUrl;
  final bool isUploading;
  final VoidCallback onPickImage;
  final VoidCallback onRemoveImage;

  const EditProfileAvatar({
    super.key,
    required this.displayAvatarUrl,
    required this.isUploading,
    required this.onPickImage,
    required this.onRemoveImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.bottomRight,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AppColors.primary, Color(0xFFFFB347)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.3),
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              padding: const EdgeInsets.all(3),
              child: Container(
                decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.bgLight),
                padding: const EdgeInsets.all(2),
                child: ClipOval(
                  child: displayAvatarUrl.isNotEmpty
                      ? Image.network(
                          displayAvatarUrl,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, lp) => lp == null ? child : const Center(child: AppLoading(size: 20)),
                          errorBuilder: (context, e, st) => const Icon(Icons.person, size: 50, color: AppColors.grey),
                        )
                      : const Icon(Icons.person, size: 50, color: AppColors.grey),
                ),
              ),
            ),
            if (isUploading)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.black.withValues(alpha: 0.6)),
                  child: const Center(child: AppLoading(size: 30, color: Colors.white)),
                ),
              ),
            GestureDetector(
              onTap: isUploading ? null : onPickImage,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 3),
                ),
                child: const Icon(Icons.camera_alt_rounded, size: 18, color: AppColors.white),
              ),
            ),
          ],
        ),
        if (displayAvatarUrl.isNotEmpty)
          TextButton(
            onPressed: isUploading ? null : onRemoveImage,
            child: const Text(
              'Xóa ảnh hiện tại',
              style: TextStyle(color: AppColors.danger, fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}
