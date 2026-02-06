import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/email_confirmation_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final emailConfirmationServiceProvider = Provider((ref) {
  return EmailConfirmationService();
});

final verifyOTPProvider = NotifierProvider.family<OTPNotifier, bool, String>(OTPNotifier.new);
class OTPNotifier extends Notifier<bool> {
  final String email;
  OTPNotifier(this.email);
  late final EmailConfirmationService _service;

  @override
  bool build() {
    _service = ref.watch(emailConfirmationServiceProvider);
    return false;
  }

  Future<bool> verifyOTP(String token) async {
    state = true;
    try { 
      await _service.verifyOTP(email: email, token: token, type: OtpType.signup);
      state = false;
      return true; 
    } catch (e) {
      state = false;
      rethrow; 
    }
  }
}

final resendEmailProvider = NotifierProvider.family<ResendNotifier, bool, String>(ResendNotifier.new);
class ResendNotifier extends Notifier<bool> {
  final String email;
  ResendNotifier(this.email);
  late final EmailConfirmationService _service;

  @override
  bool build() {
    _service = ref.watch(emailConfirmationServiceProvider);
    return false;
  }

  Future<void> resendEmail() async {
    state = true;
    try {
      await _service.resendSignupEmail(email);
    } finally {
      state = false;
    }
  }
}
