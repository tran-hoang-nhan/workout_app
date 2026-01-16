import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/registration_transaction_service.dart';
import '../models/auth.dart';
import '../models/health_params.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/health_repository.dart';

final registrationTransactionServiceProvider = Provider<RegistrationTransactionService>((ref) {
  final authRepo = ref.watch(Provider((ref) => AuthRepository()));
  final healthRepo = ref.watch(Provider((ref) => HealthRepository()));
  return RegistrationTransactionService(
    authRepo: authRepo,
    healthRepo: healthRepo,
  );
});

final registrationTransactionProvider = AsyncNotifierProvider<RegistrationTransactionController, void>(() {
  return RegistrationTransactionController();
});

class RegistrationTransactionController extends AsyncNotifier<void> {
  @override
  Future<void> build() async {}

  Future<AppUser?> completeRegistration({required SignUpParams signUpParams, required HealthUpdateParams healthParams,}) async {
    state = const AsyncValue.loading();
    try {
      final service = ref.read(registrationTransactionServiceProvider);
      final user = await service.completeRegistration(
        signUpParams: signUpParams,
        healthParams: healthParams,
      );
      state = const AsyncValue.data(null);
      return user;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      rethrow;
    }
  }
}
