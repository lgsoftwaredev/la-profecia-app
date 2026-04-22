import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../app/router/app_router.dart';
import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/global_bottom_menu.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../game_mode_selection/presentation/pages/home_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../providers/premium_providers.dart';
import '../providers/purchase_providers.dart';

class PremiumMenuPage extends ConsumerStatefulWidget {
  const PremiumMenuPage({
    this.showBottomMenu = true,
    this.onGlobalMenuRequested,
    super.key,
  });

  final bool showBottomMenu;
  final ValueChanged<GlobalBottomMenuItem>? onGlobalMenuRequested;

  @override
  ConsumerState<PremiumMenuPage> createState() => _PremiumMenuPageState();
}

class _PremiumMenuPageState extends ConsumerState<PremiumMenuPage> {
  static const _policiesUrl =
      'https://www.laprofecia.app/condiciones-y-politicas';
  static const _premiumExtraBenefits = <String>[
    'Nuevo nivel:\nInframundo.',
    'Cartas exclusivas y\npersonalizadas.',
    'Eventos mucho más\nintensos.',
    'Sistema de efectos\nvigentes.',
    'Sistema de\npreferencias.',
    'Crea retos y\npreguntas.',
  ];

  @override
  void initState() {
    super.initState();
    Future<void>(() async {
      final isAuthenticated = ref.read(isAuthenticatedProvider);
      await ref
          .read(analyticsServiceProvider)
          .logPremiumCtaViewed(
            source: 'premium_menu',
            isGuest: !isAuthenticated,
          );
      await ref.read(purchaseControllerProvider.notifier).refreshCatalog();
      await ref.read(premiumAccessProvider.notifier).refresh();
    });
  }

  Future<void> _purchase() async {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      final didLogin = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute<bool>(builder: (_) => const LoginPage()));
      if (didLogin != true || !mounted) {
        return;
      }
    }
    await ref.read(purchaseControllerProvider.notifier).purchaseMonthly();
    if (!mounted) {
      return;
    }
    final message = ref.read(purchaseControllerProvider).message;
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _restore() async {
    final isAuthenticated = ref.read(isAuthenticatedProvider);
    if (!isAuthenticated) {
      final didLogin = await Navigator.of(
        context,
      ).push<bool>(MaterialPageRoute<bool>(builder: (_) => const LoginPage()));
      if (didLogin != true || !mounted) {
        return;
      }
    }
    await ref.read(purchaseControllerProvider.notifier).restore();
    if (!mounted) {
      return;
    }
    final message = ref.read(purchaseControllerProvider).message;
    if (message != null && message.isNotEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _openPolicies() async {
    final opened = await launchUrl(
      Uri.parse(_policiesUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo abrir el enlace')),
      );
    }
  }

  void _closePremiumMenu() {
    if (widget.onGlobalMenuRequested != null) {
      widget.onGlobalMenuRequested!(GlobalBottomMenuItem.home);
      return;
    }

    final navigator = Navigator.of(context);
    if (navigator.canPop()) {
      navigator.pop();
      return;
    }
    navigator.pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const HomePage()),
    );
  }

  Future<void> _onBottomMenuItemSelected(GlobalBottomMenuItem item) async {
    if (widget.onGlobalMenuRequested != null) {
      widget.onGlobalMenuRequested!(item);
      return;
    }

    if (item == GlobalBottomMenuItem.ranking) {
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

    if (item == GlobalBottomMenuItem.profile) {
      await AppRouter.openProfileGuarded(context, replace: true);
      return;
    }

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final purchaseState = ref.watch(purchaseControllerProvider);
    final isPremium = ref.watch(premiumAccessProvider);
    final monthlyOffer = purchaseState.catalog.isNotEmpty
        ? purchaseState.catalog.first
        : null;

    return Scaffold(
      extendBody: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: const AssetImage('assets/background-premium.png'),
                  fit: BoxFit.cover,
                  alignment: Alignment.bottomCenter,
                ),
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                2,
                AppSpacing.lg,
                170,
              ),
              child: Column(
                children: [
                  Row(
                    children: [
                      const Spacer(),
                      IconButton(
                        onPressed: _closePremiumMenu,
                        icon: const Icon(Icons.close_rounded),
                        color: Colors.white,
                        iconSize: 36,
                      ),
                    ],
                  ),
                  Image.asset(
                    'assets/logo-simple-premium.png',
                    width: 210,
                    fit: BoxFit.contain,
                  ),
                  Text.rich(
                    TextSpan(
                      text: 'La Profecía ',
                      children: [
                        TextSpan(
                          text: 'sin límites',
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                color: const Color(0xFFF0D148),
                                fontWeight: FontWeight.w700,
                              ),
                        ),
                      ],
                    ),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Todos los niveles, más personalizado y\nsin interrupciones.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      height: 1.28,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _PremiumBenefitsPanel(extraBenefits: _premiumExtraBenefits),
                  const SizedBox(height: AppSpacing.md),
                  Image.asset(
                    'assets/divider-premium.png',
                    fit: BoxFit.contain,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    'Selecciona tu plan',
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      Expanded(
                        child: _PlanCard(
                          titleNumber: '1',
                          title: 'Semana',
                          price: '\$1.99',
                          selected: false,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: _PlanCard(
                          titleNumber: '1',
                          title: 'Mes',
                          price: monthlyOffer?.price ?? '\$4.99',
                          oldPrice: '\$7.98',
                          discountLabel: '-37,5%',
                          selected: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  _PremiumCtaButton(
                    loading: purchaseState.loading,
                    enabled: !isPremium,
                    label: isPremium ? 'Premium activo' : 'Empezar ahora',
                    onTap: _purchase,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    'Cancela cuando quieras. Gracias por apoyarnos, duramos\nmeses construyéndolo para ti.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.8),
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  TextButton(
                    onPressed: _openPolicies,
                    child: Text(
                      'Condiciones - politicas',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.95),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: purchaseState.loading ? null : _restore,
                    child: Text(
                      'Restaurar compra',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white.withValues(alpha: 0.7),
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
              currentItem: GlobalBottomMenuItem.ranking,
              onItemSelected: _onBottomMenuItemSelected,
            )
          : null,
    );
  }
}

class _PremiumBenefitsPanel extends StatelessWidget {
  const _PremiumBenefitsPanel({required this.extraBenefits});

  final List<String> extraBenefits;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        border: Border.all(color: const Color(0xFFDBB436), width: 1.2),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xA81A1C2A),
            const Color(0xC90C0F19),
            const Color(0xE306070B),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _PlanSideCard(
                  title: 'Sin premium',
                  titleIcon: null,
                  items: [
                    _SideItem(
                      text: 'Nivel cielo.',
                      icon: Image.asset(
                        'assets/cielo-icon-logo.png',
                        width: 22,
                        height: 22,
                        fit: BoxFit.contain,
                      ),
                    ),
                    _SideItem(
                      text: 'Con anuncios.',
                      icon: Image.asset(
                        'assets/logo-icon-megaphone-anuncio.png',
                        width: 20,
                        height: 20,
                        fit: BoxFit.contain,
                        color: Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: _PlanSideCard(
                  title: 'Premium',
                  titleIcon: Image.asset(
                    'assets/logo-icon-premium-corona.png',
                    width: 24,
                    height: 24,
                  ),
                  items: const [
                    _SideItem(text: 'Acceso a todos los niveles.'),
                    _SideItem(text: 'Sin anuncios.'),
                  ],
                  highlighted: true,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var row = 0; row < 3; row++) ...[
            Row(
              children: [
                Expanded(child: _BenefitRow(text: extraBenefits[row * 2])),
                const SizedBox(width: AppSpacing.sm),
                Expanded(child: _BenefitRow(text: extraBenefits[row * 2 + 1])),
              ],
            ),
            if (row != 2) const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _PlanSideCard extends StatelessWidget {
  const _PlanSideCard({
    required this.title,
    required this.items,
    required this.titleIcon,
    this.highlighted = false,
  });

  final String title;
  final List<_SideItem> items;
  final Widget? titleIcon;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        border: highlighted == false
            ? Border.all(
                color: const Color.fromARGB(255, 151, 151, 151),
                width: 1.2,
              )
            : null,

        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            highlighted ? const Color(0x8A6B4A1E) : const Color(0x8A272A36),
            const Color(0xCC0A0D14),
          ],
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (titleIcon != null) ...[titleIcon!, const SizedBox(width: 6)],
              Text(
                title,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.96),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var index = 0; index < items.length; index++) ...[
            _MiniLabel(icon: items[index].icon, text: items[index].text),
            if (index != items.length - 1)
              const SizedBox(height: AppSpacing.xs),
          ],
        ],
      ),
    );
  }
}

class _SideItem {
  const _SideItem({required this.text, this.icon});

  final String text;
  final Widget? icon;
}

class _MiniLabel extends StatelessWidget {
  const _MiniLabel({required this.text, this.icon});

  final String text;
  final Widget? icon;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSpacing.xs,
        vertical: AppSpacing.xxs,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
      ),
      child: Row(
        children: [
          icon ??
              Image.asset(
                'assets/logo-icon-check-premium.png',
                width: 18,
                height: 18,
                fit: BoxFit.contain,
              ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.94),
                fontWeight: FontWeight.w500,
                height: 1.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 54,
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: const Color(0xFF0A0D13).withValues(alpha: 0.95),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Image.asset(
            'assets/logo-icon-check-premium.png',
            width: 24,
            height: 24,
            fit: BoxFit.contain,
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.94),
                fontWeight: FontWeight.w500,
                height: 1.05,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PlanCard extends StatelessWidget {
  const _PlanCard({
    required this.titleNumber,
    required this.title,
    required this.price,
    required this.selected,
    this.oldPrice,
    this.discountLabel,
  });

  final String titleNumber;
  final String title;
  final String price;
  final bool selected;
  final String? oldPrice;
  final String? discountLabel;

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 144),
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            16,
            AppSpacing.md,
            14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: selected
                  ? const Color(0xFFE6C84A)
                  : Colors.white.withValues(alpha: 0.58),
              width: selected ? 2.8 : 1.2,
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [const Color(0xB7383D4A), const Color(0xCC10131E)],
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Align(
                alignment: Alignment.topRight,
                child: Icon(
                  selected
                      ? Icons.check_circle_outline_rounded
                      : Icons.circle_outlined,
                  color: Colors.white.withValues(alpha: 0.96),
                ),
              ),
              Text(
                titleNumber,
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  height: 0.95,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    price,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: const Color(0xFFF1CF57),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (oldPrice != null) ...[
                    const SizedBox(width: 5),
                    Text(
                      oldPrice!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: const Color(0xFFB86767),
                        decoration: TextDecoration.lineThrough,
                        decorationColor: const Color(0xFFB86767),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
        if (discountLabel != null)
          Positioned(
            top: -10,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.md,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8CF66),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  discountLabel!,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFF5B4A00),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class _PremiumCtaButton extends StatelessWidget {
  const _PremiumCtaButton({
    required this.label,
    required this.enabled,
    required this.loading,
    required this.onTap,
  });

  final String label;
  final bool enabled;
  final bool loading;
  final Future<void> Function() onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: !enabled || loading ? null : () => onTap(),
        borderRadius: BorderRadius.circular(999),
        child: Ink(
          height: 72,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFFFBE35A), Color(0xFFF0A13F)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFF8D145).withValues(alpha: 0.25),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Center(
            child: loading
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2.2),
                  )
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Image.asset(
                        'assets/logo-icon-premium-corona.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.contain,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        label,
                        style: Theme.of(context).textTheme.headlineSmall
                            ?.copyWith(
                              color: const Color(0xFF985A1A),
                              fontWeight: FontWeight.w700,
                            ),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}
