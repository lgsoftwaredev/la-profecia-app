import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/global_bottom_menu.dart';
import '../../../game_mode_selection/presentation/pages/home_page.dart';
import '../../../player_setup/presentation/widgets/premium_glass_surface.dart';
import '../../../premium/presentation/pages/premium_menu_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../controllers/auth_session_store.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _bottomMenuItem = GlobalBottomMenuItem.profile;

  void _onBottomMenuSelected(GlobalBottomMenuItem item) {
    if (item == GlobalBottomMenuItem.home) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomePage()),
        (route) => false,
      );
      return;
    }
    if (item == GlobalBottomMenuItem.ranking) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const PremiumMenuPage()));
      return;
    }
    if (item == GlobalBottomMenuItem.settings) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const SettingsPage()));
      return;
    }

    setState(() {
      _bottomMenuItem = item;
    });
  }

  Future<void> _openRegister() async {
    final didSignIn = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute<bool>(builder: (_) => const RegisterPage()));
    if (!mounted || didSignIn != true) {
      return;
    }
    Navigator.of(context).pop(true);
  }

  void _login() {
    AuthSessionStore.signIn();
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
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
                      padding: const EdgeInsets.only(bottom: 170),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: AppSpacing.sm),
                          _AuthLabel(text: 'Correo'),
                          const SizedBox(height: AppSpacing.xs),
                          const _AuthInputField(
                            icon: Icons.mail_outline_rounded,
                            hintText: 'Correo',
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          _AuthLabel(text: 'Escribe tu contraseña'),
                          const SizedBox(height: AppSpacing.xs),
                          const _AuthInputField(
                            icon: Icons.lock_outline_rounded,
                            hintText: '*****',
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
                            text: 'Iniciar sesión',
                            onTap: _login,
                          ),
                          const SizedBox(height: AppSpacing.md),
                          const _DividerLabel(text: 'O Inicia'),
                          const SizedBox(height: AppSpacing.md),
                          const _SocialButtonsRow(),
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
      bottomNavigationBar: GlobalBottomMenu(
        currentItem: _bottomMenuItem,
        onItemSelected: _onBottomMenuSelected,
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
  const _AuthInputField({required this.icon, required this.hintText});

  final IconData icon;
  final String hintText;

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
            child: Text(
              hintText,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: Colors.white.withValues(alpha: 0.40),
                fontWeight: FontWeight.w500,
                fontSize: 32 * 0.52,
              ),
            ),
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
  const _SocialButtonsRow();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: const [
        Expanded(
          child: _SocialButton(
            asset: 'assets/logo-icon-google.png',
            dark: false,
          ),
        ),
        SizedBox(width: AppSpacing.md),
        Expanded(
          child: _SocialButton(asset: 'assets/logo-icon-apple.png', dark: true),
        ),
      ],
    );
  }
}

class _SocialButton extends StatelessWidget {
  const _SocialButton({required this.asset, required this.dark});

  final String asset;
  final bool dark;

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
      child: Center(
        child: Image.asset(asset, width: 28, height: 28, fit: BoxFit.contain),
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
