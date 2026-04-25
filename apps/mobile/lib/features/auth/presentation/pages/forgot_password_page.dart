import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/auth_providers.dart';
import '../../../player_setup/presentation/widgets/premium_glass_surface.dart';

class ForgotPasswordPage extends ConsumerStatefulWidget {
  const ForgotPasswordPage({this.initialEmail, super.key});

  final String? initialEmail;

  @override
  ConsumerState<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends ConsumerState<ForgotPasswordPage> {
  late final TextEditingController _emailController = TextEditingController(
    text: widget.initialEmail?.trim() ?? '',
  );
  final _codeController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  var _codeSent = false;
  var _obscureNewPassword = true;
  var _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _codeController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _sendCode() async {
    final email = _emailController.text.trim();
    if (email.isEmpty || !_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un correo valido.')),
      );
      return;
    }

    final authController = ref.read(authControllerProvider);
    final ok = await authController.sendPasswordResetCode(email: email);
    if (!mounted) {
      return;
    }
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authController.errorMessage ??
                'No se pudo enviar el codigo de recuperación.',
          ),
        ),
      );
      return;
    }

    setState(() {
      _codeSent = true;
    });
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Código enviado a $email')));
  }

  Future<void> _resetPassword() async {
    final email = _emailController.text.trim();
    final code = _codeController.text.trim();
    final password = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (email.isEmpty || !_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un correo valido.')),
      );
      return;
    }
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa el codigo de recuperación.')),
      );
      return;
    }
    if (password.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La contraseña debe tener al menos 6 caracteres.'),
        ),
      );
      return;
    }
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden.')),
      );
      return;
    }

    final authController = ref.read(authControllerProvider);
    final ok = await authController.resetPasswordWithCode(
      email: email,
      code: code,
      newPassword: password,
    );
    if (!mounted) {
      return;
    }
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authController.errorMessage ??
                'No se pudo restablecer la contraseña.',
          ),
        ),
      );
      return;
    }

    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Contraseña actualizada'),
          content: const Text(
            'Ya puedes iniciar sesión con tu nueva contraseña.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Entendido'),
            ),
          ],
        );
      },
    );

    if (mounted && Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(isAuthLoadingProvider);

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background-home.png', fit: BoxFit.cover),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 132,
                        child: Align(
                          alignment: Alignment.topLeft,
                          child: _HeaderSideButton(
                            onTap: () => Navigator.of(context).pop(),
                          ),
                        ),
                      ),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(height: AppSpacing.xxl * 1.8),
                          Image.asset(
                            'assets/logo-icon-signin-user.png',
                            width: 104,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text(
                            'Olvidé mi contraseña',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.96),
                                  fontWeight: FontWeight.w700,
                                  fontSize: 50 * 0.56,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                        ],
                      ),
                    ],
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      keyboardDismissBehavior:
                          ScrollViewKeyboardDismissBehavior.onDrag,
                      padding: const EdgeInsets.only(bottom: 170),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            _codeSent
                                ? 'Ingresa el código recibido por correo y define tu nueva contraseña.'
                                : 'Ingresa tu correo y te enviaremos un código de recuperación.',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.78),
                                  fontSize: 27 * 0.50,
                                  height: 1.3,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          const _AuthLabel(text: 'Correo'),
                          const SizedBox(height: AppSpacing.xs),
                          _AuthInputField(
                            icon: Icons.mail_outline_rounded,
                            hintText: 'Correo',
                            controller: _emailController,
                          ),
                          if (_codeSent) ...[
                            const SizedBox(height: AppSpacing.sm),
                            const _AuthLabel(text: 'Código'),
                            const SizedBox(height: AppSpacing.xs),
                            _AuthInputField(
                              icon: Icons.password_rounded,
                              hintText: 'Código de 6 dígitos',
                              controller: _codeController,
                              keyboardType: TextInputType.number,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const _AuthLabel(text: 'Nueva contraseña'),
                            const SizedBox(height: AppSpacing.xs),
                            _AuthInputField(
                              icon: Icons.lock_outline_rounded,
                              hintText: '******',
                              controller: _newPasswordController,
                              obscureText: _obscureNewPassword,
                              trailingIcon: _obscureNewPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              onTrailingTap: () {
                                setState(() {
                                  _obscureNewPassword = !_obscureNewPassword;
                                });
                              },
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            const _AuthLabel(text: 'Confirmar contraseña'),
                            const SizedBox(height: AppSpacing.xs),
                            _AuthInputField(
                              icon: Icons.lock_outline_rounded,
                              hintText: '******',
                              controller: _confirmPasswordController,
                              obscureText: _obscureConfirmPassword,
                              trailingIcon: _obscureConfirmPassword
                                  ? Icons.visibility_off_rounded
                                  : Icons.visibility_rounded,
                              onTrailingTap: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                          ],
                          const SizedBox(height: AppSpacing.lg),
                          _PrimaryAuthButton(
                            text: isSubmitting
                                ? 'Procesando...'
                                : (_codeSent
                                      ? 'Restablecer contraseña'
                                      : 'Enviar código'),
                            onTap: _codeSent ? _resetPassword : _sendCode,
                          ),
                          if (_codeSent) ...[
                            const SizedBox(height: AppSpacing.md),
                            Align(
                              child: GestureDetector(
                                onTap: isSubmitting ? null : _sendCode,
                                child: Text(
                                  'Reenviar código',
                                  style: Theme.of(context).textTheme.titleMedium
                                      ?.copyWith(
                                        color: const Color(0xFF36A5FF),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 27 * 0.50,
                                      ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AuthLabel extends StatelessWidget {
  const _AuthLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        color: Colors.white.withValues(alpha: 0.92),
        fontWeight: FontWeight.w700,
        fontSize: 30 * 0.52,
      ),
    );
  }
}

class _AuthInputField extends StatelessWidget {
  const _AuthInputField({
    required this.icon,
    required this.hintText,
    required this.controller,
    this.keyboardType,
    this.trailingIcon,
    this.onTrailingTap,
    this.obscureText = false,
  });

  final IconData icon;
  final String hintText;
  final TextEditingController controller;
  final TextInputType? keyboardType;
  final IconData? trailingIcon;
  final VoidCallback? onTrailingTap;
  final bool obscureText;

  @override
  Widget build(BuildContext context) {
    return PremiumGlassSurface(
      height: 62,
      borderRadius: BorderRadius.circular(16),
      gradientColors: [
        const Color(0xFF252A37).withValues(alpha: 0.84),
        const Color(0xFF0C1018).withValues(alpha: 0.94),
      ],
      borderColor: Colors.white.withValues(alpha: 0.18),
      innerBorderColor: Colors.white.withValues(alpha: 0.05),
      topHighlightOpacity: 0.10,
      bottomShadeOpacity: 0.12,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              color: const Color(0xFF5E667A).withValues(alpha: 0.34),
            ),
            child: Icon(
              icon,
              size: 24,
              color: Colors.white.withValues(alpha: 0.84),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: TextField(
              controller: controller,
              onTapOutside: (_) =>
                  FocusManager.instance.primaryFocus?.unfocus(),
              keyboardType: keyboardType,
              obscureText: obscureText,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.88),
                fontWeight: FontWeight.w500,
                fontSize: 32 * 0.52,
              ),
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: hintText,
                hintStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.40),
                  fontWeight: FontWeight.w500,
                  fontSize: 32 * 0.52,
                ),
              ),
            ),
          ),
          if (trailingIcon != null && onTrailingTap != null)
            IconButton(
              onPressed: onTrailingTap,
              icon: Icon(
                trailingIcon,
                size: 22,
                color: Colors.white.withValues(alpha: 0.72),
              ),
            )
          else if (trailingIcon != null)
            Icon(
              trailingIcon,
              size: 22,
              color: Colors.white.withValues(alpha: 0.72),
            ),
        ],
      ),
    );
  }
}

class _PrimaryAuthButton extends StatelessWidget {
  const _PrimaryAuthButton({required this.text, required this.onTap});

  final String text;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: PremiumGlassSurface(
        height: 62,
        borderRadius: BorderRadius.circular(16),
        gradientColors: const [Color(0xFFF7F8FA), Color(0xFFE4E7EE)],
        borderColor: Colors.white.withValues(alpha: 0.25),
        innerBorderColor: Colors.white.withValues(alpha: 0.14),
        topHighlightOpacity: 0.14,
        bottomShadeOpacity: 0.10,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Center(
              child: Text(
                text,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF4D586D),
                  fontWeight: FontWeight.w700,
                  fontSize: 32 * 0.56,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _HeaderSideButton extends StatelessWidget {
  const _HeaderSideButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 44,
      height: 44,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(999),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(999),
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0xFF14172A).withValues(alpha: 0.90),
                  const Color(0xFF070B17).withValues(alpha: 0.78),
                ],
              ),
              border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
            ),
            child: Center(
              child: Icon(
                Icons.chevron_left_rounded,
                size: 24,
                color: Colors.white.withValues(alpha: 0.84),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
