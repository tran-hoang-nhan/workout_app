import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/email_confirmation_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

final emailConfirmationServiceProvider = Provider((ref) {
  return EmailConfirmationService();
});

// State cho verify OTP
final verifyOTPProvider =
    StateNotifierProvider.family<OTPNotifier, bool, String>((ref, email) {
  final service = ref.watch(emailConfirmationServiceProvider);
  return OTPNotifier(service, email);
});

class OTPNotifier extends StateNotifier<bool> {
  final EmailConfirmationService _service;
  final String email;

  OTPNotifier(this._service, this.email) : super(false);

  Future<void> verifyOTP(String token) async {
    state = true;
    try {
      await _service.verifyOTP(
        email: email,
        token: token,
        type: OtpType.signup,
      );
    } finally {
      state = false;
    }
  }
}

// State cho resend email
final resendEmailProvider =
    StateNotifierProvider.family<ResendNotifier, bool, String>((ref, email) {
  final service = ref.watch(emailConfirmationServiceProvider);
  return ResendNotifier(service, email);
});

class ResendNotifier extends StateNotifier<bool> {
  final EmailConfirmationService _service;
  final String email;

  ResendNotifier(this._service, this.email) : super(false);

  Future<void> resendEmail() async {
    state = true;
    try {
      await _service.resendSignupEmail(email);
    } finally {
      state = false;
    }
  }
}
