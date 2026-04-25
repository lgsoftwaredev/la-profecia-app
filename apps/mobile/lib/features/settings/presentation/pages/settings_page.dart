import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../app/router/app_router.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/global_bottom_menu.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../game_mode_selection/presentation/pages/home_page.dart';
import '../../../premium/presentation/pages/premium_menu_page.dart';
import '../../../premium/presentation/providers/premium_providers.dart';
import '../../../suggestions/domain/entities/suggestion.dart';
import '../../../suggestions/presentation/pages/suggestion_compose_final_group_page.dart';
import '../../../player_setup/presentation/widgets/premium_glass_surface.dart';
import '../../../tutorial/presentation/pages/tutorial_page.dart';
import 'liquid_glass_demo_page.dart';

class SettingsPage extends ConsumerStatefulWidget {
  const SettingsPage({
    this.showBottomMenu = true,
    this.onGlobalMenuRequested,
    super.key,
  });

  final bool showBottomMenu;
  final ValueChanged<GlobalBottomMenuItem>? onGlobalMenuRequested;

  @override
  ConsumerState<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends ConsumerState<SettingsPage> {
  var _soundEnabled = true;

  Future<void> _onBottomMenuItemSelected(GlobalBottomMenuItem item) async {
    if (widget.onGlobalMenuRequested != null) {
      widget.onGlobalMenuRequested!(item);
      return;
    }

    if (item == GlobalBottomMenuItem.settings) {
      return;
    }

    if (item == GlobalBottomMenuItem.home) {
      final navigator = Navigator.of(context);
      if (navigator.canPop()) {
        navigator.popUntil((route) => route.isFirst);
        return;
      }
      navigator.pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const HomePage()),
      );
      return;
    }

    if (item == GlobalBottomMenuItem.ranking) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute<void>(builder: (_) => const PremiumMenuPage()),
      );
      return;
    }

    await AppRouter.openProfileGuarded(context, replace: true);
  }

  void _openPremium() {
    if (widget.onGlobalMenuRequested != null) {
      widget.onGlobalMenuRequested!(GlobalBottomMenuItem.ranking);
      return;
    }

    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const PremiumMenuPage()));
  }

  Future<SuggestionType?> _pickSuggestionType() {
    return showModalBottomSheet<SuggestionType>(
      context: context,
      backgroundColor: const Color(0xFF0E1220),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        return SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.lg,
              AppSpacing.xl,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Qué quieres proponer?',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  tileColor: Colors.white.withValues(alpha: 0.06),
                  title: const Text(
                    'Pregunta',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(SuggestionType.question),
                ),
                const SizedBox(height: AppSpacing.sm),
                ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  tileColor: Colors.white.withValues(alpha: 0.06),
                  title: const Text(
                    'Reto',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () =>
                      Navigator.of(sheetContext).pop(SuggestionType.challenge),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _openSuggestionFlow() async {
    final container = ProviderScope.containerOf(context, listen: false);
    final isPremium = container.read(premiumAccessProvider);
    if (!isPremium) {
      _openPremium();
      return;
    }

    final type = await _pickSuggestionType();
    if (type == null || !mounted) {
      return;
    }
    final isAuthenticated = container.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      await showDialog<void>(
        context: context,
        builder: (dialogContext) {
          return AlertDialog(
            title: const Text('Inicia sesión'),
            content: const Text(
              'Debes iniciar sesión para proponer contenido.',
            ),
            actions: [
              FilledButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Entendido'),
              ),
            ],
          );
        },
      );
      return;
    }
    if (!mounted) {
      return;
    }
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SuggestionComposeFinalGroupPage(type: type),
      ),
    );
  }

  Future<void> _confirmDeleteAccount() async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Eliminar cuenta'),
          content: const Text(
            'Esta accion es irreversible. ¿Seguro que quieres eliminar tu cuenta?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC83A3A),
              ),
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Eliminar'),
            ),
          ],
        );
      },
    );
    if (shouldDelete != true || !mounted) {
      return;
    }

    await ref.read(authControllerProvider).signOut();
    if (!mounted) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Cuenta eliminada.')));
    if (widget.onGlobalMenuRequested != null) {
      widget.onGlobalMenuRequested!(GlobalBottomMenuItem.home);
      return;
    }

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.popUntil((route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumAccessProvider);

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
                  Row(
                    children: [
                      Text(
                        'Setting',
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              color: Colors.white.withValues(alpha: 0.95),
                              fontWeight: FontWeight.w700,
                              fontSize: 50 * 0.66,
                            ),
                      ),
                      const Spacer(),
                      _HeaderSideButton(
                        onTap: () {
                          if (widget.onGlobalMenuRequested != null) {
                            widget.onGlobalMenuRequested!(
                              GlobalBottomMenuItem.home,
                            );
                            return;
                          }
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
                        children: [
                          const SizedBox(height: AppSpacing.lg),
                          _SettingsItemRow(
                            iconAsset: 'assets/logo-icon-sound.png',
                            title: 'Sonido',
                            trailing: _SoundSwitch(
                              enabled: _soundEnabled,
                              onChanged: (value) {
                                setState(() {
                                  _soundEnabled = value;
                                });
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _SettingsItemRow(
                            iconAsset: 'assets/logo-icon-ver-tutorial.png',
                            title: 'Ver tutorial',
                            onTap: () {
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute<void>(
                                  builder: (_) => const TutorialPage(),
                                ),
                                (route) => false,
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _SettingsItemRow(
                            iconAsset: 'assets/logo-icon-foco-premium.png',
                            title: 'Demo Liquid Glass+',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute<void>(
                                  builder: (_) => const LiquidGlassDemoPage(),
                                ),
                              );
                            },
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _SettingsItemRow(
                            iconAsset:
                                'assets/logo-icon-proponer-questions.png',
                            title: 'Proponer retos y preguntas',
                            premiumSubtitle: true,
                            onTap: isPremium
                                ? _openSuggestionFlow
                                : _openPremium,
                          ),
                          if (!isPremium) ...[
                            const SizedBox(height: AppSpacing.xl),
                            _SettingsItemRow(
                              iconAsset:
                                  'assets/logo-icon-premium-corona-outlined.png',
                              title: 'Desbloquear',
                              trailing: _PremiumBadge(),
                              onTap: _openPremium,
                            ),
                          ],
                          const SizedBox(height: AppSpacing.xl),
                          const _SettingsItemRow(
                            iconAsset: 'assets/logo-icon-acercade.png',
                            title: 'Acerca de',
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          const _SettingsItemRow(
                            iconAsset: 'assets/logo-icon-audifonos.png',
                            title: 'Soporte',
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          _SettingsItemRow(
                            iconAsset: 'assets/logo-icon-lock.png',
                            title: 'Eliminar cuenta',
                            onTap: _confirmDeleteAccount,
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Text(
                            'La Profecia no es responsable de las consecuencias',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.72),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 28 * 0.50,
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
      bottomNavigationBar: widget.showBottomMenu
          ? GlobalBottomMenu(
              currentItem: GlobalBottomMenuItem.settings,
              onItemSelected: _onBottomMenuItemSelected,
            )
          : null,
    );
  }
}

class _SettingsItemRow extends StatelessWidget {
  const _SettingsItemRow({
    required this.iconAsset,
    required this.title,
    this.premiumSubtitle = false,
    this.trailing,
    this.onTap,
  });

  final String iconAsset;
  final String title;
  final bool premiumSubtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final item = PremiumGlassSurface(
      height: 74,
      borderRadius: BorderRadius.circular(20),
      gradientColors: [
        const Color(0xFF232833).withValues(alpha: 0.84),
        const Color(0xFF0A0D14).withValues(alpha: 0.95),
      ],
      borderColor: Colors.white.withValues(alpha: 0.18),
      innerBorderColor: Colors.white.withValues(alpha: 0.05),
      topHighlightOpacity: 0.10,
      bottomShadeOpacity: 0.14,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              color: const Color(0xFF1A1F28).withValues(alpha: 0.82),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Image.asset(
              iconAsset,
              width: 23,
              height: 23,
              fit: BoxFit.contain,
              color: Colors.white.withValues(alpha: 0.68),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: premiumSubtitle
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white.withValues(alpha: 0.92),
                          fontWeight: FontWeight.w500,
                          fontSize: 34 * 0.56,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 1),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Image.asset(
                            'assets/premium-icon-logo.png',
                            width: 15,
                            height: 15,
                            fit: BoxFit.contain,
                            color: const Color(0xFFF1B63B),
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Premium',
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(
                                  color: const Color(0xFFF1B63B),
                                  fontWeight: FontWeight.w700,
                                  fontStyle: FontStyle.italic,
                                  fontSize: 26 * 0.50,
                                ),
                          ),
                        ],
                      ),
                    ],
                  )
                : Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white.withValues(alpha: 0.92),
                      fontWeight: FontWeight.w500,
                      fontSize: 34 * 0.56,
                    ),
                  ),
          ),
          trailing ?? const SizedBox.shrink(),
        ],
      ),
    );

    if (onTap == null) {
      return item;
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: item,
      ),
    );
  }
}

class _SoundSwitch extends StatelessWidget {
  const _SoundSwitch({required this.enabled, required this.onChanged});

  final bool enabled;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Transform.scale(
      scale: 0.88,
      child: Switch(
        value: enabled,
        onChanged: onChanged,
        activeThumbColor: Colors.white,
        activeTrackColor: const Color(0xFF2D323D),
        inactiveThumbColor: Colors.white.withValues(alpha: 0.92),
        inactiveTrackColor: const Color(0xFF2A2F39),
        trackOutlineColor: WidgetStatePropertyAll(
          Colors.white.withValues(alpha: 0.10),
        ),
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
    );
  }
}

class _PremiumBadge extends StatelessWidget {
  const _PremiumBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 40,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(999),
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFFFFE55D), Color(0xFFF0A91B)],
        ),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/premium-icon-logo.png',
            width: 18,
            height: 18,
            fit: BoxFit.contain,
            color: const Color(0xFF865E00),
          ),
          const SizedBox(width: AppSpacing.xxs),
          Text(
            'Premium',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: const Color(0xFF865E00),
              fontWeight: FontWeight.w700,
              fontStyle: FontStyle.italic,
              fontSize: 28 * 0.52,
            ),
          ),
        ],
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
