import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_3d_pill_button.dart';
import '../../../../core/widgets/global_bottom_menu.dart';
import '../../../profile/presentation/pages/profile_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class PremiumMenuPage extends StatefulWidget {
  const PremiumMenuPage({super.key});

  @override
  State<PremiumMenuPage> createState() => _PremiumMenuPageState();
}

class _PremiumMenuPageState extends State<PremiumMenuPage> {
  var _bottomMenuItem = GlobalBottomMenuItem.ranking;

  static const _benefits = <String>[
    'Acceso a todos los niveles',
    'Inframundo',
    'Cartas exclusivas +18',
    'Eventos más intensos',
    'Sin interrupciones',
    'Sin anuncios',
  ];

  void _onBottomMenuSelected(GlobalBottomMenuItem item) {
    if (item == GlobalBottomMenuItem.home) {
      if (Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
      return;
    }
    if (item == GlobalBottomMenuItem.profile) {
      Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const ProfilePage()));
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
                  const Color(0x54060314),
                  const Color(0xFF06020F).withValues(alpha: 0.98),
                ],
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.84, -1.02),
                radius: 0.92,
                colors: [Color(0xA06E3A0B), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.only(bottom: 180),
                      child: Column(
                        children: [
                          const SizedBox(height: AppSpacing.md),
                          Image.asset(
                            'assets/premium-icon-logo.png',
                            width: 72,
                            height: 54,
                            fit: BoxFit.contain,
                            color: const Color(0xFFF6CD41),
                          ),
                          const SizedBox(height: AppSpacing.xs),
                          Image.asset(
                            'assets/logo-+18.png',
                            width: 170,
                            fit: BoxFit.contain,
                          ),
                          const SizedBox(height: AppSpacing.xl),
                          Text.rich(
                            TextSpan(
                              text: 'El descenso completo\n',
                              children: [
                                TextSpan(
                                  text: 'no es gratuito.',
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineMedium
                                      ?.copyWith(
                                        color: const Color(0xFFE9BF31),
                                        fontWeight: FontWeight.w700,
                                        fontSize: 52 * 0.64,
                                        height: 1.1,
                                      ),
                                ),
                              ],
                            ),
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.95),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 52 * 0.64,
                                  height: 1.1,
                                ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Algunos límites cuestan.',
                            textAlign: TextAlign.center,
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(
                                  color: Colors.white.withValues(alpha: 0.82),
                                  fontWeight: FontWeight.w500,
                                  fontSize: 34 * 0.56,
                                ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          _PremiumHintRow(),
                          const SizedBox(height: AppSpacing.md),
                          _BenefitsCard(benefits: _benefits),
                          const SizedBox(height: AppSpacing.lg),
                          const _PremiumCtaButton(),
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

class _PremiumHintRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(
          width: 60,
          height: 60,
          child: Center(
            child: Image.asset(
              'assets/logo-icon-premium-container.png',
              width: 60,
              height: 60,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Text.rich(
            TextSpan(
              children: [
                TextSpan(
                  text: 'Hasta ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontStyle: FontStyle.italic,
                  ),
                ),
                TextSpan(
                  text: 'Premium',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontStyle: FontStyle.italic,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                TextSpan(
                  text: ' y desbloquea los\ndemás estilos de juego',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.95),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.xs),
        Container(
          height: 42,
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
                width: 20,
                height: 20,
                fit: BoxFit.contain,
                color: const Color(0xFF865E00),
              ),
              const SizedBox(width: AppSpacing.xxs),
              Text(
                'Premium',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFF865E00),
                  fontWeight: FontWeight.w700,
                  fontSize: 30 * 0.56,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _BenefitsCard extends StatelessWidget {
  const _BenefitsCard({required this.benefits});

  final List<String> benefits;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFD7A11A), width: 1.2),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF3A2B18).withValues(alpha: 0.84),
            const Color(0xFF0B0E14).withValues(alpha: 0.94),
          ],
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Image.asset(
                'assets/premium-icon-logo.png',
                width: 24,
                height: 24,
                fit: BoxFit.contain,
                color: const Color(0xFFF1C646),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Beneficios',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.98),
                  fontWeight: FontWeight.w700,
                  fontSize: 34 * 0.56,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          for (var index = 0; index < benefits.length; index++) ...[
            _BenefitRow(text: benefits[index]),
            if (index != benefits.length - 1)
              const SizedBox(height: AppSpacing.sm),
          ],
          const SizedBox(height: AppSpacing.md),
          Text.rich(
            TextSpan(
              text: 'La versión ',
              children: [
                TextSpan(
                  text: 'GRATUITA',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' es solo un aperitivo.\n'),
                TextSpan(
                  text: 'PREMIUM',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: const Color(0xFFF2BF2A),
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const TextSpan(text: ' es la experiencia completa.'),
              ],
            ),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.82),
              fontSize: 27 * 0.55,
              height: 1.25,
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
        color: const Color(0xFF0A0D13).withValues(alpha: 0.92),
        border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: const Color(0xFF11151E),
              border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
            ),
            child: Image.asset(
              'assets/logo-icon-checked.png',
              width: 18,
              height: 18,
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.94),
                fontWeight: FontWeight.w500,
                fontSize: 30 * 0.54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumCtaButton extends StatelessWidget {
  const _PremiumCtaButton();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final iconLeft = (constraints.maxWidth * 0.20)
            .clamp(24, 120)
            .toDouble();

        return SizedBox(
          height: 74,
          child: Stack(
            children: [
              App3dPillButton(
                label: 'Quiero ser Premium',
                color: const Color(0xFFFFE661),
                gradientColors: const [Color(0xFFFFE95C), Color(0xFFF0A43B)],
                height: 66,
                depth: 4.2,
                borderRadius: 18,
                textStyle: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: const Color(0xFFA66700),
                  fontWeight: FontWeight.w700,
                  fontSize: 33 * 0.56,
                ),
                onTap: () {},
              ),
              Positioned(
                left: iconLeft,
                top: 20,
                child: IgnorePointer(
                  child: Image.asset(
                    'assets/premium-icon-logo.png',
                    width: 24,
                    height: 24,
                    fit: BoxFit.contain,
                    color: const Color(0xFFA66700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
