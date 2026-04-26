import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared/shared.dart';
import '../services/registration_transaction_service.dart';

final registrationTransactionServiceProvider = Provider<RegistrationTransactionService>((ref) {
  return RegistrationTransactionService();
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
