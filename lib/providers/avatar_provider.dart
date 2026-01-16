import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/avatar_service.dart';
import './auth_provider.dart';

final avatarServiceProvider = Provider((ref) {
  return AvatarService();
});

final avatarControllerProvider = AsyncNotifierProvider<AvatarController, void>(() {
  return AvatarController();
});

class AvatarController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<void> pickAndUploadAvatar() async {
    final picker = ImagePicker();
    final image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 75,
    );

    if (image == null) {
      debugPrint('AvatarController: No image selected');
      return;
    }

    debugPrint('AvatarController: Image selected: ${image.path}');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('Chưa đăng nhập');

      final bytes = await image.readAsBytes();
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}_${image.name}';

      await ref.read(avatarServiceProvider).uploadAvatar(
        userId: user.id,
        bytes: bytes,
        fileName: fileName,
      );
      
      debugPrint('AvatarController: Upload completed, invalidating currentUserProvider');
      // Refresh user data to show new avatar
      ref.invalidate(currentUserProvider);
    });

    if (state.hasError) {
      debugPrint('AvatarController Error (pickAndUploadAvatar): ${state.error}');
    }
  }

  Future<void> removeAvatar() async {
    debugPrint('AvatarController: Starting removeAvatar');
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('Chưa đăng nhập');

      await ref.read(avatarServiceProvider).removeAvatar(user.id);
      
      debugPrint('AvatarController: Removal completed, invalidating currentUserProvider');
      // Refresh user data
      ref.invalidate(currentUserProvider);
    });

    if (state.hasError) {
      debugPrint('AvatarController Error (removeAvatar): ${state.error}');
    }
  }
}
