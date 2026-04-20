import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import 'package:shared/shared.dart';
import '../../utils/app_error.dart';
import 'register_screen.dart';
import 'email_confirmation_screen.dart';
import '../../providers/email_confirmation_provider.dart';
import 'widgets/forgot_password_dialog.dart';
import 'widgets/auth_input_field.dart';
import 'widgets/auth_password_field.dart';
import 'widgets/auth_submit_button.dart';
import 'widgets/auth_logo_section.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final Future<void> Function() onLoginSuccess;

  const LoginScreen({super.key, required this.onLoginSuccess});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late TextEditingController emailController;
  late TextEditingController passwordController;

  bool showPassword = false;
  bool isLoading = false;
  String authError = '';

  @override
  void initState() {
    super.initState();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> handleLogin() async {
    if (!_validateInputs()) return;

    setState(() => authError = '');

    try {
      final params = SignInParams(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
      );

      await ref.read(authControllerProvider.notifier).signIn(params);

      final authState = ref.read(authControllerProvider);
      if (authState.hasError) {
        final error = authState.error;
        final errorMessage = error is AppError
            ? error.userMessage
            : error.toString();

        // Kiểm tra nếu lỗi là chưa xác nhận email
        if (error is AppError && error.code == 'email_not_confirmed') {
          final email = emailController.text.trim();

          if (mounted) {
            // Tự động gửi lại mã xác nhận
            ref.read(resendEmailProvider(email).notifier).resendEmail();

            // Thông báo cho user
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(
                  'Tài khoản chưa xác thực. Đang gửi lại mã xác nhận...',
                ),
                backgroundColor: AppColors.info,
              ),
            );

            // Chuyển sang màn hình xác nhận
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => EmailConfirmationScreen(email: email),
              ),
            );
          }
          return;
        }

        setState(() => authError = errorMessage);
        return;
      }

      if (mounted) {
        await widget.onLoginSuccess();
      }
    } catch (e) {
      if (mounted) {
        final errorMessage = e is AppError ? e.userMessage : e.toString();

        // Tương tự, kiểm tra lỗi ném ra từ catch (nếu có)
        if (e is AppError && e.code == 'email_not_confirmed') {
          final email = emailController.text.trim();
          ref.read(resendEmailProvider(email).notifier).resendEmail();
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => EmailConfirmationScreen(email: email),
            ),
          );
          return;
        }

        setState(() => authError = errorMessage);
      }
    }
  }

  bool _validateInputs() {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      setState(() => authError = 'Vui lòng điền đầy đủ thông tin');
      return false;
    }
    return true;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgLight,
      body: Stack(
        children: [
          // Subtle background decorative elements
          Positioned(
            top: -MediaQuery.of(context).size.height * 0.2,
            right: -MediaQuery.of(context).size.width * 0.1,
            child: Container(
              width: 300,
              height: 240,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.primary.withValues(alpha: 0.1),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          // Main Content
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 450,
                    minHeight:
                        MediaQuery.of(context).size.height -
                        MediaQuery.of(context).padding.top -
                        MediaQuery.of(context).padding.bottom -
                        40,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo & Title
                      const AuthLogoSection(),
                      const SizedBox(height: AppSpacing.xxl),
                      // Auth Card
                      _buildAuthCard(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAuthCard() {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: AppColors.black.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.xl),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            const Text(
              'Chào mừng trở lại',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Đăng nhập để tiếp tục tập luyện',
              style: TextStyle(fontSize: 14, color: AppColors.grey),
            ),
            const SizedBox(height: AppSpacing.xl),
            // Form
            _buildForm(),
            // Error Message
            if (authError.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.md),
              _buildErrorMessage(),
            ],
            // Submit Button
            const SizedBox(height: AppSpacing.xl),
            AuthSubmitButton(
              text: 'Đăng nhập',
              isLoading: ref.watch(authControllerProvider).isLoading,
              onTap: handleLogin,
            ),
            // Forgot Password Link
            const SizedBox(height: AppSpacing.md),
            _buildForgotPasswordLink(),
            // Toggle Mode Link
            const SizedBox(height: AppSpacing.xl),
            _buildSignupLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: _showForgotPasswordDialog,
        child: const Text(
          'Quên mật khẩu?',
          style: TextStyle(
            color: AppColors.primary,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildForm() {
    return AutofillGroup(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AuthInputField(
            label: 'Email',
            icon: Icons.mail_outline,
            controller: emailController,
            placeholder: 'email@example.com',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthPasswordField(controller: passwordController),
        ],
      ),
    );
  }

  Future<void> _showForgotPasswordDialog() async {
    return showDialog(
      context: context,
      builder: (context) =>
          ForgotPasswordDialog(initialEmail: emailController.text),
    );
  }

  Widget _buildSignupLink() {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Chưa có tài khoản? ',
              style: TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        RegisterScreen(onSignupSuccess: widget.onLoginSuccess),
                  ),
                );
              },
              child: const Text(
                'Đăng ký ngay',
                style: TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        authError,
        style: TextStyle(color: Colors.red.shade400, fontSize: 12),
      ),
    );
  }
}
