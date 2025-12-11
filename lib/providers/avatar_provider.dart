import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/avatar_service.dart';

final avatarServiceProvider = Provider((ref) {
  return AvatarService();
});
