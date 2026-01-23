import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../widgets/custom_button.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../providers/auth_provider.dart';

class PasswordRecoveryScreen extends ConsumerStatefulWidget {
  final String email;

  const PasswordRecoveryScreen({super.key, required this.email});

  @override
  ConsumerState<PasswordRecoveryScreen> createState() =>
      _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState
    extends ConsumerState<PasswordRecoveryScreen> {
  final _otpController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _otpVerified = false;
  int _resendCountdown = 0;

  @override
  void dispose() {
    _otpController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);
    _tick();
  }

  void _tick() {
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() => _resendCountdown--);
        _tick();
      }
    });
  }

  Future<void> _handleVerifyOTP() async {
    final otp = _otpController.text.trim();
    if (otp.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Vui lòng nhập mã xác nhận')),
      );
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .verifyRecoveryOTP(widget.email, otp);
    if (success) {
      setState(() => _otpVerified = true);
    } else {
      if (mounted) {
        final state = ref.read(authControllerProvider);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Xác thực thất bại: ${state.error}')),
        );
      }
    }
  }

  Future<void> _handleUpdatePassword() async {
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (password.isEmpty) return;
    if (password != confirm) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mật khẩu xác nhận không khớp')),
      );
      return;
    }

    try {
      await ref.read(authControllerProvider.notifier).updatePassword(password);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mật khẩu đã được cập nhật thành công!'),
          ),
        );
        Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final isLoading = authState.isLoading;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Đặt lại mật khẩu'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                const SizedBox(height: AppSpacing.lg),
                _buildHeader(),
                const SizedBox(height: AppSpacing.xl),
                if (!_otpVerified)
                  _buildOtpSection(isLoading)
                else
                  AutofillGroup(child: _buildNewPasswordSection(isLoading)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(AppSpacing.lg),
          decoration: BoxDecoration(
            color: AppColors.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppBorderRadius.full),
          ),
          child: Icon(
            _otpVerified ? Icons.lock_reset : Icons.security,
            size: 60,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: AppSpacing.lg),
        Text(
          _otpVerified ? 'Nhập mật khẩu mới' : 'Xác nhận mã OTP',
          style: const TextStyle(
            fontSize: AppFontSize.xxxl,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        Text(
          _otpVerified
              ? 'Mật khẩu mới của bạn phải khác mật khẩu cũ.'
              : 'Mã xác nhận đã được gửi đến:\n${widget.email}',
          style: const TextStyle(color: AppColors.grey),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildOtpSection(bool isLoading) {
    return Column(
      children: [
        CustomTextField(
          label: 'Mã OTP',
          hintText: 'Nhập mã 6 chữ số',
          controller: _otpController,
          prefixIcon: Icons.key_outlined,
          keyboardType: TextInputType.number,
        ),
        const SizedBox(height: AppSpacing.xl),
        CustomButton(
          label: 'Xác Nhận Mã',
          isLoading: isLoading,
          onPressed: _handleVerifyOTP,
        ),
        const SizedBox(height: AppSpacing.lg),
        if (_resendCountdown > 0)
          Text('Gửi lại mã trong ${_resendCountdown}s')
        else
          TextButton(
            onPressed: () {
              ref
                  .read(authControllerProvider.notifier)
                  .resetPassword(widget.email);
              _startResendCountdown();
            },
            child: const Text('Gửi lại mã xác nhận'),
          ),
      ],
    );
  }

  Widget _buildNewPasswordSection(bool isLoading) {
    return Column(
      children: [
        CustomTextField(
          label: 'Mật khẩu mới',
          hintText: 'Ít nhất 6 ký tự',
          controller: _passwordController,
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          autofillHints: const [AutofillHints.newPassword],
        ),
        const SizedBox(height: AppSpacing.md),
        CustomTextField(
          label: 'Xác nhận mật khẩu',
          hintText: 'Nhập lại mật khẩu mới',
          controller: _confirmController,
          prefixIcon: Icons.lock_outline,
          isPassword: true,
          autofillHints: const [AutofillHints.newPassword],
        ),
        const SizedBox(height: AppSpacing.xl),
        CustomButton(
          label: 'Cập nhật mật khẩu',
          isLoading: isLoading,
          onPressed: _handleUpdatePassword,
        ),
      ],
    );
  }
}
