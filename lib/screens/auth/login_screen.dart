import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../controllers/auth_controller.dart';
import '../../core/config/supabase_config.dart';
import '../../services/auth_service.dart';
import '../../theme/app_colors.dart';
import '../../widgets/app_text_field.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController(
    text: SupabaseConfig.isDemoMode ? AuthService.adminEmail : '',
  );
  final _password = TextEditingController(
    text: SupabaseConfig.isDemoMode ? AuthService.adminPassword : '',
  );
  bool _obscure = true;
  bool _isSignUp = false;

  final AuthController _auth = Get.find<AuthController>();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      if (_isSignUp) {
        _auth.signUp(_email.text, _password.text);
      } else {
        _auth.signIn(_email.text, _password.text);
      }
    }
  }

  /// Fills the form with the admin credentials and signs in immediately.
  /// Wired to a double-tap on the admin account card.
  void _loginAsAdmin() {
    if (_auth.isLoading.value) return;
    if (_isSignUp) setState(() => _isSignUp = false);
    _email.text = AuthService.adminEmail;
    _password.text = AuthService.adminPassword;
    _auth.signIn(_email.text, _password.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Brand gradient backdrop.
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.primary, AppColors.primaryDark],
              ),
            ),
          ),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Card(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _logo(context),
                          const SizedBox(height: 24),
                          Text(
                            _isSignUp ? 'Create account' : 'Welcome back',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _isSignUp
                                ? 'Sign up for the Yammo Admin Portal'
                                : 'Sign in to the Yammo Admin Portal',
                            textAlign: TextAlign.center,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.copyWith(color: AppColors.textSecondary),
                          ),
                          const SizedBox(height: 28),
                          AppTextField(
                            label: 'Email',
                            controller: _email,
                            hint: 'admin@example.com',
                            prefixIcon: Icons.mail_outline,
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) =>
                                (v == null || !v.contains('@'))
                                    ? 'Enter a valid email'
                                    : null,
                          ),
                          const SizedBox(height: 16),
                          AppTextField(
                            label: 'Password',
                            controller: _password,
                            hint: '••••••••',
                            prefixIcon: Icons.lock_outline,
                            obscureText: _obscure,
                            validator: (v) => (v == null || v.length < 6)
                                ? 'Minimum 6 characters'
                                : null,
                            suffix: IconButton(
                              icon: Icon(_obscure
                                  ? Icons.visibility_outlined
                                  : Icons.visibility_off_outlined),
                              onPressed: () =>
                                  setState(() => _obscure = !_obscure),
                            ),
                          ),
                          if (!_isSignUp)
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () =>
                                    Get.toNamed<void>(AppRoutes.forgotPassword),
                                child: const Text('Forgot password?'),
                              ),
                            )
                          else
                            const SizedBox(height: 8),
                          const SizedBox(height: 8),
                          Obx(
                            () => SizedBox(
                              height: 50,
                              child: ElevatedButton(
                                onPressed:
                                    _auth.isLoading.value ? null : _submit,
                                child: _auth.isLoading.value
                                    ? const SizedBox(
                                        height: 22,
                                        width: 22,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2.4,
                                          color: Colors.white,
                                        ),
                                      )
                                    : Text(_isSignUp
                                        ? 'Create account'
                                        : 'Sign In'),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          _adminAccountCard(context),
                          const SizedBox(height: 8),
                          _modeToggle(context),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _logo(BuildContext context) {
    return Center(
      child: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.accent],
          ),
          borderRadius: BorderRadius.circular(18),
        ),
        child: const Icon(Icons.palette_outlined, color: Colors.white, size: 34),
      ),
    );
  }

  /// Admin account shortcut — double-tap to auto-fill the form and sign in.
  Widget _adminAccountCard(BuildContext context) {
    return Obx(
      () => Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onDoubleTap: _auth.isLoading.value ? null : _loginAsAdmin,
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.06),
              borderRadius: BorderRadius.circular(12),
              border:
                  Border.all(color: AppColors.primary.withValues(alpha: 0.25)),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.primary.withValues(alpha: 0.15),
                  child: const Icon(
                    Icons.admin_panel_settings_outlined,
                    color: AppColors.primary,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Admin account',
                        style: Theme.of(context)
                            .textTheme
                            .titleSmall
                            ?.copyWith(fontWeight: FontWeight.w600),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        AuthService.adminEmail,
                        style: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
                Text(
                  'Double-click\nto sign in',
                  textAlign: TextAlign.right,
                  style: Theme.of(context)
                      .textTheme
                      .labelSmall
                      ?.copyWith(color: AppColors.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _modeToggle(BuildContext context) {
    return Wrap(
      alignment: WrapAlignment.center,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        Text(
          _isSignUp ? 'Already have an account?' : "Don't have an account?",
          style: Theme.of(context)
              .textTheme
              .bodyMedium
              ?.copyWith(color: AppColors.textSecondary),
        ),
        TextButton(
          onPressed: () => setState(() => _isSignUp = !_isSignUp),
          child: Text(_isSignUp ? 'Sign in' : 'Sign up'),
        ),
      ],
    );
  }

}
