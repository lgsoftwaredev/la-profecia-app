import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../providers/auth_providers.dart';
import '../../../player_setup/presentation/widgets/premium_glass_surface.dart';
import 'register_page.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({super.key});

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  var _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _openRegister() async {
    final result = await Navigator.of(context).push<String>(
      MaterialPageRoute<String>(builder: (_) => const RegisterPage()),
    );
    if (!mounted) {
      return;
    }
    if (result != registerEmailConfirmationRequiredResult) {
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirma tu correo'),
          content: const Text(
            'Debe confirmar su email en su bandeja de correo.',
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
  }

  Future<void> _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();
    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa correo y contrasena.')),
      );
      return;
    }
    if (!_isValidEmail(email)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa un correo valido.')),
      );
      return;
    }

    final authController = ref.read(authControllerProvider);
    final ok = await authController.signInWithEmail(
      email: email,
      password: password,
    );
    if (!mounted) {
      return;
    }
    if (!ok) {
      final message =
          authController.errorMessage ?? 'No se pudo iniciar sesion.';
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
      return;
    }
    Navigator.of(context).pop(true);
  }

  bool _isValidEmail(String email) {
    final regex = RegExp(r'^[^\s@]+@[^\s@]+\.[^\s@]+$');
    return regex.hasMatch(email);
  }

  Future<void> _loginWithGoogle() async {
    final authController = ref.read(authControllerProvider);
    final ok = await authController.signInWithGoogle();
    if (!mounted) {
      return;
    }
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authController.errorMessage ?? 'No se pudo iniciar con Google.',
          ),
        ),
      );
      return;
    }
    Navigator.of(context).pop(true);
  }

  Future<void> _loginWithApple() async {
    final authController = ref.read(authControllerProvider);
    final ok = await authController.signInWithApple();
    if (!mounted) {
      return;
    }
    if (!ok) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            authController.errorMessage ?? 'No se pudo iniciar con Apple.',
          ),
        ),
      );
      return;
    }
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    final isSubmitting = ref.watch(isAuthLoadingProvider);
    final showAppleButton =
        !kIsWeb &&
        (defaultTargetPlatform == TargetPlatform.iOS ||
            defaultTargetPlatform == TargetPlatform.macOS);

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset('assets/background-home.png', fit: BoxFit.cover),
          DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  const Color(0x59060315),
                  const Color(0xFF06020F).withValues(alpha: 0.98),
                ],
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.86, -1.0),
                radius: 0.92,
                colors: [Color(0x59315C96), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: [
                      Text(
                        'Iniciar',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.96),
                              fontWeight: FontWeight.w700,
                              fontSize: 50 * 0.66,
                            ),
                      ),
                      const Spacer(),
                      _HeaderSideButton(
                        onTap: () {
                          if (Navigator.of(context).canPop()) {
                            Navigator.of(context).pop();
                          }
                        },
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
                          const SizedBox(height: AppSpacing.sm),
                          _AuthLabel(text: 'Correo'),
                          const SizedBox(height: AppSpacing.xs),
                          _AuthInputField(
                            icon: Icons.mail_outline_rounded,
                            hintText: 'Correo',
                            controller: _emailController,
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _AuthLabel(text: 'Escribe tu contraseña'),
                          const SizedBox(height: AppSpacing.xs),
                          _AuthInputField(
                            icon: Icons.lock_outline_rounded,
                            hintText: '*****',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            trailingIcon: _obscurePassword
                                ? Icons.visibility_off_rounded
                                : Icons.visibility_rounded,
                            onTrailingTap: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Align(
                            child: Text(
                              '¿Olvidaste la contraseña?',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(
                                    color: const Color(0xFF36A5FF),
                                    fontWeight: FontWeight.w600,
                                    fontSize: 27 * 0.50,
                                  ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _PrimaryAuthButton(
                            text: isSubmitting
                                ? 'Cargando...'
                                : 'Iniciar sesión',
                            onTap: _login,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const _DividerLabel(text: 'O Inicia'),
                          const SizedBox(height: AppSpacing.md),
                          _SocialButtonsRow(
                            onGoogleTap: _loginWithGoogle,
                            onAppleTap: _loginWithApple,
                            showAppleButton: showAppleButton,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Align(
                            child: GestureDetector(
                              onTap: _openRegister,
                              child: Text.rich(
                                TextSpan(
                                  text: '¿Aun no tienes una cuenta? ',
                                  children: [
                                    TextSpan(
                                      text: 'Regístrate',
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: const Color(0xFF36A5FF),
                                            fontWeight: FontWeight.w700,
                                          ),
                                    ),
                                  ],
                                ),
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.78,
                                      ),
                                      fontSize: 27 * 0.50,
                                    ),
                              ),
                            ),
                          ),
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
    this.trailingIcon,
    this.onTrailingTap,
    this.obscureText = false,
  });

  final IconData icon;
  final String hintText;
  final TextEditingController controller;
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

class _DividerLabel extends StatelessWidget {
  const _DividerLabel({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            height: 1.4,
            color: Colors.white.withValues(alpha: 0.36),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: Text(
            text,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              fontWeight: FontWeight.w500,
              fontSize: 29 * 0.50,
            ),
          ),
        ),
        Expanded(
          child: Container(
            height: 1.4,
            color: Colors.white.withValues(alpha: 0.36),
          ),
        ),
      ],
    );
  }
}

class _SocialButtonsRow extends StatelessWidget {
  const _SocialButtonsRow({
    required this.onGoogleTap,
    required this.onAppleTap,
    required this.showAppleButton,
  });

  final VoidCallback onGoogleTap;
  final VoidCallback onAppleTap;
  final bool showAppleButton;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SocialButton(
            asset: 'assets/logo-icon-google.png',
            dark: false,
            onTap: onGoogleTap,
          ),
        ),
        if (showAppleButton) ...[
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: _SocialButton(
              asset: 'assets/logo-icon-apple.png',
              dark: true,
              onTap: onAppleTap,
            ),
          ),
        ],
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({
    required this.asset,
    required this.dark,
    required this.onTap,
  });

  final String asset;
  final bool dark;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return PremiumGlassSurface(
      height: 62,
      borderRadius: BorderRadius.circular(16),
      gradientColors: dark
          ? [
              const Color(0xFF242A36).withValues(alpha: 0.72),
              const Color(0xFF0F131A).withValues(alpha: 0.90),
            ]
          : const [Color(0xFFF7F8FA), Color(0xFFE4E7EE)],
      borderColor: Colors.white.withValues(alpha: dark ? 0.16 : 0.24),
      innerBorderColor: Colors.white.withValues(alpha: dark ? 0.05 : 0.14),
      topHighlightOpacity: 0.10,
      bottomShadeOpacity: 0.10,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Center(
            child: Image.asset(
              asset,
              width: 28,
              height: 28,
              fit: BoxFit.contain,
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
      width: 48,
      height: 86,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(26),
          onTap: onTap,
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(26),
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
                size: 34,
                color: Colors.white.withValues(alpha: 0.84),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
