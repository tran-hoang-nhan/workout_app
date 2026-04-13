import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import 'package:shared/shared.dart';
import '../../utils/app_error.dart';
import '../../widgets/loading_animation.dart';
import 'login_screen.dart';
import 'email_confirmation_screen.dart';
import 'widgets/auth_input_field.dart';
import 'widgets/auth_password_field.dart';
import 'widgets/auth_submit_button.dart';
import 'widgets/auth_logo_section.dart';
import 'widgets/auth_date_picker_field.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final Future<void> Function() onSignupSuccess;

  const RegisterScreen({super.key, required this.onSignupSuccess});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;
  DateTime? _selectedDate;

  bool showPassword = false;
  bool showConfirmPassword = false;
  bool isLoading = false;
  String authError = '';

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    passwordController = TextEditingController();
    confirmPasswordController = TextEditingController();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> handleSignup() async {
    if (!_validateInputs()) return;

    setState(() => authError = '');

    try {
      final params = SignUpParams(
        email: emailController.text.trim(),
        password: passwordController.text.trim(),
        fullName: nameController.text.trim(),
        dateOfBirth: _selectedDate,
      );

      await ref.read(authControllerProvider.notifier).signUp(params);

      final authState = ref.read(authControllerProvider);
      if (authState.hasError) {
        final error = authState.error;
        setState(
          () => authError = error is AppError
              ? error.userMessage
              : error.toString(),
        );
        return;
      }

      final authService = ref.read(authServiceProvider);
      if (authService.isAuthenticated) {
        await widget.onSignupSuccess();
        if (mounted) {
          Navigator.of(context).pop();
        }
      } else {
        if (mounted) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (_) => EmailConfirmationScreen(email: params.email),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(
          () => authError = e is AppError ? e.userMessage : e.toString(),
        );
      }
    }
  }

  bool _validateInputs() {
    final name = nameController.text.trim();
    final email = emailController.text.trim();
    final password = passwordController.text.trim();
    final confirmPassword = confirmPasswordController.text.trim();

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => authError = 'Vui lòng điền đầy đủ thông tin');
      return false;
    }

    if (password.length < 6) {
      setState(() => authError = 'Mật khẩu phải có ít nhất 6 ký tự');
      return false;
    }

    if (password != confirmPassword) {
      setState(() => authError = 'Mật khẩu không khớp');
      return false;
    }

    if (_selectedDate == null) {
      setState(() => authError = 'Vui lòng chọn ngày sinh');
      return false;
    }

    return true;
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
              onPrimary: AppColors.white,
              onSurface: AppColors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(foregroundColor: AppColors.primary),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
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
            left: -MediaQuery.of(context).size.width * 0.1,
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
              'Đăng Ký Tài Khoản',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.black,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: AppSpacing.xs),
            const Text(
              'Điền thông tin để bắt đầu hành trình tập luyện',
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
              text: 'Đăng ký',
              isLoading: ref.watch(authControllerProvider).isLoading,
              onTap: handleSignup,
            ),
            // Toggle Mode Link
            const SizedBox(height: AppSpacing.lg),
            _buildLoginLink(),
          ],
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
            label: 'Họ và tên',
            icon: Icons.person,
            controller: nameController,
            placeholder: 'Nguyễn Văn A',
            autofillHints: const [AutofillHints.name],
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthDatePickerField(
            label: 'Ngày sinh',
            icon: Icons.calendar_today,
            value: _selectedDate == null
                ? ''
                : '${_selectedDate!.day.toString().padLeft(2, '0')}/${_selectedDate!.month.toString().padLeft(2, '0')}/${_selectedDate!.year}',
            placeholder: 'DD/MM/YYYY',
            onTap: _selectDate,
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthInputField(
            label: 'Email',
            icon: Icons.mail_outline,
            controller: emailController,
            placeholder: 'email@example.com',
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthPasswordField(
            label: 'Mật khẩu',
            controller: passwordController,
          ),
          const SizedBox(height: AppSpacing.lg),
          AuthPasswordField(
            label: 'Xác nhận mật khẩu',
            controller: confirmPasswordController,
          ),
        ],
      ),
    );
  }

  Widget _buildLoginLink() {
    return Center(
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Đã có tài khoản? ',
              style: TextStyle(color: AppColors.grey, fontSize: 14),
            ),
            GestureDetector(
              onTap: () {
                Navigator.of(context).pushReplacement(
                  MaterialPageRoute(
                    builder: (_) =>
                        LoginScreen(onLoginSuccess: widget.onSignupSuccess),
                  ),
                );
              },
              child: const Text(
                'Đăng nhập ngay',
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
