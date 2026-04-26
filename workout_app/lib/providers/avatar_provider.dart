import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../services/avatar_service.dart';
import './auth_provider.dart';

final avatarServiceProvider = Provider((ref) {
  return AvatarService();
});

final avatarControllerProvider = AsyncNotifierProvider<AvatarController, void>(
  () {
    return AvatarController();
  },
);

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
      return;
    }

    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('Chưa đăng nhập');
      final bytes = await image.readAsBytes();
      final fileName = 'avatar_${DateTime.now().millisecondsSinceEpoch}_${image.name}';
      await ref.read(avatarServiceProvider).uploadAvatar(userId: user.id, bytes: bytes, fileName: fileName);
      ref.invalidate(currentUserProvider);
    });

    if (state.hasError) {
    }
  }

  Future<void> removeAvatar() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(currentUserProvider.future);
      if (user == null) throw Exception('Chưa đăng nhập');
      await ref.read(avatarServiceProvider).removeAvatar(user.id);
      ref.invalidate(currentUserProvider);
    });

    if (state.hasError) {
    }
  }
}
