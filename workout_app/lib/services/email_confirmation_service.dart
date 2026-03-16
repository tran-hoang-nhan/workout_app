import '../repositories/auth_repository.dart';

class EmailConfirmationService {
  final AuthRepository _repository;
  EmailConfirmationService({AuthRepository? repository}): _repository = repository ?? AuthRepository();

  Future<void> verifyOTP({required String email, required String token, required String type,}) async {
    await _repository.verifyOTP(email: email, token: token, type: type);
  }

  Future<void> resendSignupEmail(String email) async {
    await _repository.resendOTP(email: email, type: 'signup');
  }
}
