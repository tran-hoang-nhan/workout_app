import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_text_field.dart';
import '../../providers/email_confirmation_provider.dart';

class EmailConfirmationScreen extends ConsumerStatefulWidget {
  final String email;

  const EmailConfirmationScreen({
    super.key,
    required this.email,
  });

  @override
  ConsumerState<EmailConfirmationScreen> createState() =>
      _EmailConfirmationScreenState();
}

class _EmailConfirmationScreenState
    extends ConsumerState<EmailConfirmationScreen> {
  final _otpController = TextEditingController();
  int _resendCountdown = 0;

  @override
  void dispose() {
    _otpController.dispose();
    super.dispose();
  }

  void _startResendCountdown() {
    setState(() => _resendCountdown = 60);
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted && _resendCountdown > 0) {
        setState(() => _resendCountdown--);
        _startResendCountdown();
      }
    });
  }

  Future<void> _handleVerifyOTP() async {
    if (_otpController.text.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng nhập mã xác nhận'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
      return;
    }

    try {
      final success = await ref.read(verifyOTPProvider(widget.email).notifier).verifyOTP(_otpController.text.trim());
      if (success && mounted) {
        // Hiển thị thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Xác nhận email thành công!'),
            backgroundColor: AppColors.success,
            duration: Duration(seconds: 2),
          ),
        );
        
        // Chờ 500ms để user thấy thông báo, sau đó pop về màn hình trước (health onboard)
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.danger,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isVerifying = ref.watch(verifyOTPProvider(widget.email));
    final isResending = ref.watch(resendEmailProvider(widget.email));
    final isLoading = isVerifying || isResending;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(AppBorderRadius.full),
                  ),
                  child: const Icon(
                    Icons.security_outlined,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Xác Thực Email',
                  style: TextStyle(
                    fontSize: AppFontSize.xxxl,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: const TextStyle(
                      fontSize: AppFontSize.md,
                      color: AppColors.grey,
                      height: 1.5,
                    ),
                    children: [
                      const TextSpan(text: 'Vui lòng nhập mã xác thực gồm 6 chữ số đã được gửi đến:\n'),
                      TextSpan(
                        text: widget.email,
                        style: const TextStyle(
                          color: AppColors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                
                // OTP Input Section
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppBorderRadius.xl),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        CustomTextField(
                          label: 'Mã xác nhận',
                          hintText: '00000000',
                          controller: _otpController,
                          prefixIcon: Icons.lock_outline,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        CustomButton(
                          label: 'Xác Nhận',
                          isLoading: isLoading,
                          onPressed: () => _handleVerifyOTP(),
                        ),
                      ],
                    ),
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                // Help/Tips Section
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: AppColors.greyLight,
                    borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        'Không nhận được mã?',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.black,
                        ),
                      ),
                      SizedBox(height: AppSpacing.xs),
                      Text(
                        'Kiểm tra thư mục Spam hoặc thử gửi lại mã sau 60s.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: AppFontSize.sm,
                          color: AppColors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: AppSpacing.xl),
                
                if (_resendCountdown > 0)
                  Center(
                    child: Text(
                      'Gửi lại mã trong ${_resendCountdown}s',
                      style: const TextStyle(
                        fontSize: AppFontSize.sm,
                        color: AppColors.grey,
                      ),
                    ),
                  )
                else
                  Center(
                    child: TextButton(
                      onPressed: isLoading
                          ? null
                          : () {
                              ref.read(resendEmailProvider(widget.email).notifier).resendEmail();
                              _startResendCountdown();
                            },
                      child: const Text(
                        'Gửi lại mã xác nhận',
                        style: TextStyle(
                          fontSize: AppFontSize.md,
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
