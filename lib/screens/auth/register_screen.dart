import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../constants/app_constants.dart';
import '../../providers/auth_provider.dart';
import '../../models/auth.dart';
import 'login_screen.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  final Future<void> Function() onSignupSuccess;

  const RegisterScreen({
    super.key,
    required this.onSignupSuccess,
  });

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController passwordController;
  late TextEditingController confirmPasswordController;

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
      );

      await ref.read(authControllerProvider.notifier).signUp(params);
      
      final authState = ref.read(authControllerProvider);
      if (authState.hasError) {
        setState(() => authError = authState.error.toString());
        return;
      }

      if (mounted) {
        await widget.onSignupSuccess();
      }
    } catch (e) {
      if (mounted) {
        setState(() => authError = e.toString());
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
            left: -MediaQuery.of(context).size.width * 0.1,
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
        const Text(
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
            _buildLoginLink(),
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
          label: 'Họ và tên',
          icon: Icons.person,
          controller: nameController,
          placeholder: 'Nguyễn Văn A',
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildInputField(
          label: 'Email',
          icon: Icons.mail_outline,
          controller: emailController,
          placeholder: 'email@example.com',
          keyboardType: TextInputType.emailAddress,
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildPasswordField(
          label: 'Mật khẩu',
          controller: passwordController,
          showPassword: showPassword,
          onToggle: () {
            setState(() => showPassword = !showPassword);
          },
        ),
        const SizedBox(height: AppSpacing.lg),
        _buildPasswordField(
          label: 'Xác nhận mật khẩu',
          controller: confirmPasswordController,
          showPassword: showConfirmPassword,
          onToggle: () {
            setState(() => showConfirmPassword = !showConfirmPassword);
          },
        ),
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

  Widget _buildPasswordField({
    required String label,
    required TextEditingController controller,
    required bool showPassword,
    required VoidCallback onToggle,
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
                onTap: onToggle,
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
      onTap: isControllerLoading ? null : handleSignup,
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
                      'Đăng ký',
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

  Widget _buildLoginLink() {
    return Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'Đã có tài khoản? ',
            style: TextStyle(
              color: AppColors.grey,
              fontSize: 14,
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(
                  builder: (_) => LoginScreen(
                    onLoginSuccess: widget.onSignupSuccess,
                  ),
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
    );
  }
}
