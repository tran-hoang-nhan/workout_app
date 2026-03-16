import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../utils/validation_utils.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';
import '../../providers/auth_provider.dart';
import 'password_recovery_screen.dart';

class ForgotPasswordScreen extends ConsumerWidget {
  const ForgotPasswordScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formKey = GlobalKey<FormState>();
    final emailController = TextEditingController();
    final authState = ref.watch(authControllerProvider);

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
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  const Text(
                    'Quên Mật Khẩu?',
                    style: TextStyle(
                      fontSize: AppFontSize.xxxl,
                      fontWeight: FontWeight.bold,
                      color: AppColors.black,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const Text(
                    'Nhập email của bạn và chúng tôi sẽ gửi mã xác nhận để đặt lại mật khẩu.',
                    style: TextStyle(
                      fontSize: AppFontSize.md,
                      color: AppColors.grey,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  CustomTextField(
                    label: AppStrings.email,
                    hintText: 'Nhập email của bạn',
                    controller: emailController,
                    keyboardType: TextInputType.emailAddress,
                    prefixIcon: Icons.email_outlined,
                    validator: ValidationUtils.validateEmail,
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  CustomButton(
                    label: 'Gửi Mã Xác Nhận',
                    isLoading: authState.isLoading,
                    onPressed: () async {
                      if (formKey.currentState!.validate()) {
                        final email = emailController.text.trim();
                        try {
                          await ref
                              .read(authControllerProvider.notifier)
                              .resetPassword(email);
                          if (context.mounted) {
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    PasswordRecoveryScreen(email: email),
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'Mã xác nhận đã được gửi đến email của bạn!',
                                ),
                                backgroundColor: Colors.green,
                              ),
                            );
                          }
                        } catch (e) {
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Lỗi: $e'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Container(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    decoration: BoxDecoration(
                      color: AppColors.greyLight,
                      borderRadius: BorderRadius.circular(AppBorderRadius.lg),
                    ),
                    child: const Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '💡 Mẹo:',
                          style: TextStyle(
                            fontSize: AppFontSize.md,
                            fontWeight: FontWeight.w600,
                            color: AppColors.black,
                          ),
                        ),
                        SizedBox(height: AppSpacing.sm),
                        Text(
                          '• Kiểm tra thư mục Spam hoặc Promotions\n'
                          '• Email có thể mất vài phút để nhận\n'
                          '• Mã xác nhận sẽ hết hạn sau 10 phút',
                          style: TextStyle(
                            fontSize: AppFontSize.sm,
                            color: AppColors.grey,
                            height: 1.6,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
