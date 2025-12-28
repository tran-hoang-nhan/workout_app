import 'package:supabase_flutter/supabase_flutter.dart';
import '../repositories/auth_repository.dart';
import '../utils/app_error.dart';

class EmailConfirmationService {
  final AuthRepository _repository;
  EmailConfirmationService({AuthRepository? repository}): _repository = repository ?? AuthRepository();

  Future<void> verifyOTP({required String email, required String token, required OtpType type,}) async {
    try {
      await _repository.verifyOTP(email: email, token: token, type: type,);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> resendSignupEmail(String email) async {
    try {
      await _repository.resendOTP( type: OtpType.signup,  email: email,);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  bool isEmailVerified() {
    return _repository.isEmailVerified;
  }

  String? getCurrentUserEmail() {
    return _repository.currentUser?.email;
  }
}