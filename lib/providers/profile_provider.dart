import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/profile_repository.dart';
import '../services/profile_service.dart';


final profileRepositoryProvider = Provider<ProfileRepository>((ref) {
  return ProfileRepository();
});

final profileServiceProvider = Provider<ProfileService>((ref) {
  return ProfileService(ref);
});

