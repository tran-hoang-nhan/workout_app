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
  bool _showOtpInput = false;
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
      final success = await ref
          .read(verifyOTPProvider(widget.email).notifier)
          .verifyOTP(_otpController.text.trim());
      
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
                    Icons.mark_email_unread_outlined,
                    size: 60,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                const Text(
                  'Xác Nhận Email',
                  style: TextStyle(
                    fontSize: AppFontSize.xxxl,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Email xác nhận đã được gửi đến:\n${widget.email}',
                  style: const TextStyle(
                    fontSize: AppFontSize.md,
                    color: AppColors.grey,
                    height: 1.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                      border: Border.all(
                          color: AppColors.grey.withValues(alpha: 0.3)),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '✅ Cách 1: Nhấp Link (Khuyến Nghị)',
                          style: TextStyle(
                            fontSize: AppFontSize.md,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          '1. Mở email từ Workout App\n'
                          '2. Nhấp vào link "Confirm your email"\n'
                          '3. Bạn sẽ tự động được đăng nhập',
                          style: TextStyle(
                            fontSize: AppFontSize.sm,
                            color: AppColors.grey,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.lg),
                if (_showOtpInput) ...[
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.success.withValues(alpha: 0.05),
                        borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                        border: Border.all(
                            color: AppColors.success.withValues(alpha: 0.3)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            '🔐 Cách 2: Nhập Mã Xác Nhận',
                            style: TextStyle(
                              fontSize: AppFontSize.md,
                              fontWeight: FontWeight.w600,
                              color: AppColors.black,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          CustomTextField(
                            label: 'Mã OTP',
                            hintText: 'Nhập mã 6 chữ số từ email',
                            controller: _otpController,
                            prefixIcon: Icons.key_outlined,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          CustomButton(
                            label: 'Xác Nhận Mã',
                            isLoading: isLoading,
                            onPressed: () => _handleVerifyOTP(),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ] else ...[
                  Center(
                    child: TextButton(
                      onPressed: () => setState(() => _showOtpInput = true),
                      child: const Text(
                        'Hoặc nhập mã xác nhận từ email →',
                        style: TextStyle(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                ],
                SizedBox(
                  width: double.infinity,
                  child: Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.warning.withValues(alpha: 0.05),
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          '💡 Mẹo:',
                          style: TextStyle(
                            fontSize: AppFontSize.md,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          '• Kiểm tra thư mục Spam hoặc Promotions\n'
                          '• Có thể mất vài phút để nhận email\n'
                          '• Mã xác nhận sẽ hết hạn sau 10 phút',
                          style: TextStyle(
                            fontSize: AppFontSize.sm,
                            color: AppColors.grey,
                            height: 1.6,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
                if (_resendCountdown > 0)
                  Center(
                    child: Text(
                      'Gửi lại email trong ${_resendCountdown}s',
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
                        'Gửi lại email xác nhận',
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
