import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  final Future<void> Function() onLoginSuccess;

  const LoginScreen({
    super.key,
    required this.onLoginSuccess,
  });

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
        setState(() => authError = authState.error.toString());
        return;
      }

      if (mounted) {
        await widget.onLoginSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() => authError = e.toString());
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
              height: 300,
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
                padding: const EdgeInsets.all(AppSpacing.lg),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: 450,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Logo & Title
                      _buildLogoSection(),
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

  Widget _buildLogoSection() {
    return Column(
      children: [
        Container(
          width: 80,
          height: 80,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.primary, AppColors.primaryDark],
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Icon(
            Icons.fitness_center,
            color: Colors.white,
            size: 40,
          ),
        ),
        const SizedBox(height: AppSpacing.xl),
        const Text(
          'Workout App',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: AppColors.black,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(
          'Bắt đầu hành trình fitness của bạn',
          style: TextStyle(
            color: AppColors.grey,
            fontSize: 15,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
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
              style: TextStyle(
                fontSize: 14,
                color: AppColors.grey,
              ),
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
            _buildSubmitButton(),
            // Toggle Mode Link
            const SizedBox(height: AppSpacing.lg),
            _buildSignupLink(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildInputField(
          label: 'Email',
          icon: Icons.mail_outline,
          controller: emailController,
          placeholder: 'email@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildPasswordField(),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required IconData icon,
    required TextEditingController controller,
    required String placeholder,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.greyLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: TextField(
            controller: controller,
            keyboardType: keyboardType,
            style: const TextStyle(color: AppColors.black, fontSize: 15),
            decoration: InputDecoration(
              hintText: placeholder,
              hintStyle: const TextStyle(color: AppColors.grey, fontSize: 15),
              prefixIcon: Icon(
                icon,
                color: AppColors.grey,
                size: 20,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Mật khẩu',
          style: TextStyle(
            fontSize: 13,
            color: AppColors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Container(
          decoration: BoxDecoration(
            color: AppColors.greyLight.withValues(alpha: 0.5),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.cardBorder),
          ),
          child: TextField(
            controller: passwordController,
            obscureText: !showPassword,
            style: const TextStyle(color: AppColors.black, fontSize: 15),
            decoration: InputDecoration(
              hintText: '••••••••',
              hintStyle: const TextStyle(color: AppColors.grey, fontSize: 15),
              prefixIcon: const Icon(
                Icons.lock_outline,
                color: AppColors.grey,
                size: 20,
              ),
              suffixIcon: GestureDetector(
                onTap: () {
                  setState(() => showPassword = !showPassword);
                },
                child: Icon(
                  showPassword ? Icons.visibility_off : Icons.visibility,
                  color: AppColors.grey,
                  size: 20,
                ),
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildErrorMessage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.1),
        border: Border.all(
          color: Colors.red.withValues(alpha: 0.3),
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Text(
        authError,
        style: TextStyle(
          color: Colors.red.shade400,
          fontSize: 12,
        ),
      ),
    );
  }

  Widget _buildSubmitButton() {
    final authState = ref.watch(authControllerProvider);
    final isControllerLoading = authState.isLoading;

    return GestureDetector(
      onTap: isControllerLoading ? null : handleLogin,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isControllerLoading
                ? [Colors.grey.shade600, Colors.grey.shade700]
                : [Colors.orange.shade500, Colors.red.shade500],
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.orange.shade500.withValues(alpha: 0.3),
              blurRadius: 10,
              spreadRadius: 0,
            ),
          ],
        ),
        child: Center(
          child: isControllerLoading
              ? SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor:
                        AlwaysStoppedAnimation(Colors.grey.shade300),
                  ),
                )
              : Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Đăng nhập',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.arrow_forward,
                      color: Colors.white,
                      size: 18,
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _buildSignupLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Chưa có tài khoản? ',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => RegisterScreen(
                    onSignupSuccess: widget.onLoginSuccess,
                  ),
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
    );
  }
}
