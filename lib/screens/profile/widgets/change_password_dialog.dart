import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../constants/app_constants.dart';
import '../../../widgets/custom_text_field.dart';
import '../../../providers/auth_provider.dart';

class ChangePasswordDialog extends ConsumerStatefulWidget {
  const ChangePasswordDialog({super.key});

  @override
  ConsumerState<ChangePasswordDialog> createState() =>
      _ChangePasswordDialogState();
}

class _ChangePasswordDialogState extends ConsumerState<ChangePasswordDialog> {
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();

  @override
  void dispose() {
    passwordController.dispose();
    confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleChange() async {
    final password = passwordController.text;
    final confirm = confirmController.text;

    try {
      debugPrint('[ChangePasswordDialog] Requesting update...');
      await ref
          .read(authControllerProvider.notifier)
          .updatePassword(password, confirmPassword: confirm);
      final authState = ref.read(authControllerProvider);

      if (mounted) {
        if (authState.hasError) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text('Lỗi: ${authState.error}')));
        } else {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Đổi mật khẩu thành công!')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Lỗi không xác định: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Đổi mật khẩu'),
      content: AutofillGroup(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Nhập mật khẩu mới của bạn.'),
            const SizedBox(height: AppSpacing.md),
            CustomTextField(
              label: 'Mật khẩu mới',
              controller: passwordController,
              isPassword: true,
              autofillHints: const [AutofillHints.newPassword],
            ),
            const SizedBox(height: AppSpacing.sm),
            CustomTextField(
              label: 'Xác nhận mật khẩu',
              controller: confirmController,
              isPassword: true,
              autofillHints: const [AutofillHints.newPassword],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        ElevatedButton(onPressed: _handleChange, child: const Text('Cập nhật')),
      ],
    );
  }
}
