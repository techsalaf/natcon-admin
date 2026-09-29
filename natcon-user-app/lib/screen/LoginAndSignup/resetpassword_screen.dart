import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../controller/login_controller.dart';
import 'login_screen.dart';

class ResetPasswordScreen extends StatefulWidget {
  static String verifay = '';

  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _code = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();
  final _controller = Get.put(LoginController());
  bool _codeSent = false;
  bool _hidePassword = true;

  @override
  void dispose() {
    _email.dispose();
    _code.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _requestCode() async {
    if (!_formKey.currentState!.validate()) return;
    final result = await _controller.requestNatconPasswordReset(_email.text);
    if (!mounted) return;
    if (result['Result'] == 'true') {
      setState(() => _codeSent = true);
      Get.snackbar('Check your email', result['ResponseMsg'] ?? 'If this account exists, a code is on its way.');
    } else {
      Get.snackbar('Could not send code', result['ResponseMsg'] ?? 'Try again shortly.');
    }
  }

  Future<void> _resetPassword() async {
    if (!_formKey.currentState!.validate()) return;
    if (_password.text != _confirmPassword.text) {
      Get.snackbar('Passwords do not match', 'Enter the same new password twice.');
      return;
    }
    final result = await _controller.confirmNatconPasswordReset(
      email: _email.text,
      code: _code.text,
      password: _password.text,
    );
    if (!mounted) return;
    if (result['Result'] == 'true') {
      Get.snackbar('Password updated', result['ResponseMsg'] ?? 'Sign in with your new password.');
      Get.offAll(() => LoginScreen());
    } else {
      Get.snackbar('Could not reset password', result['ResponseMsg'] ?? 'Check the code and try again.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reset password'),
        leading: IconButton(icon: const Icon(Icons.arrow_back), onPressed: () => Get.back()),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Icon(Icons.lock_reset, size: 58, color: colors.primary),
                    const SizedBox(height: 18),
                    Text(
                      'Recover your NATCON account',
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'We will send a one-time code to the email on your account. The code expires after 15 minutes.',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 28),
                    TextFormField(
                      controller: _email,
                      enabled: !_codeSent,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(labelText: 'Account email'),
                      validator: (value) {
                        final email = value?.trim() ?? '';
                        return RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$').hasMatch(email)
                            ? null
                            : 'Enter a valid email address';
                      },
                    ),
                    if (_codeSent) ...[
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _code,
                        keyboardType: TextInputType.number,
                        maxLength: 6,
                        decoration: const InputDecoration(labelText: '6-digit email code'),
                        validator: (value) => (value?.trim().length ?? 0) == 6 ? null : 'Enter the 6-digit code',
                      ),
                      const SizedBox(height: 8),
                      TextFormField(
                        controller: _password,
                        obscureText: _hidePassword,
                        decoration: InputDecoration(
                          labelText: 'New password',
                          suffixIcon: IconButton(
                            onPressed: () => setState(() => _hidePassword = !_hidePassword),
                            icon: Icon(_hidePassword ? Icons.visibility : Icons.visibility_off),
                          ),
                        ),
                        validator: (value) => (value?.length ?? 0) >= 8 ? null : 'Use at least 8 characters',
                      ),
                      const SizedBox(height: 14),
                      TextFormField(
                        controller: _confirmPassword,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Confirm new password'),
                        validator: (value) => (value?.isNotEmpty ?? false) ? null : 'Confirm your password',
                      ),
                    ],
                    const SizedBox(height: 22),
                    GetBuilder<LoginController>(builder: (controller) {
                      return FilledButton(
                        onPressed: controller.passwordResetLoading ? null : (_codeSent ? _resetPassword : _requestCode),
                        child: controller.passwordResetLoading
                            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                            : Text(_codeSent ? 'Update password' : 'Send reset code'),
                      );
                    }),
                    if (_codeSent)
                      TextButton(
                        onPressed: _controller.passwordResetLoading ? null : () => setState(() => _codeSent = false),
                        child: const Text('Use another email or request a new code'),
                      ),
                    TextButton(onPressed: () => Get.offAll(() => LoginScreen()), child: const Text('Return to sign in')),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
