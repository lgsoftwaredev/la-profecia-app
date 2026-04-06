import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_3d_pill_button.dart';
import '../../../premium/presentation/providers/premium_providers.dart';
import '../../domain/entities/game_mode.dart';
import '../../../player_setup/presentation/pages/player_setup_page.dart';

class HomeModeCarousel extends ConsumerStatefulWidget {
  const HomeModeCarousel({super.key});

  @override
  ConsumerState<HomeModeCarousel> createState() => _HomeModeCarouselState();
}

class _HomeModeCarouselState extends ConsumerState<HomeModeCarousel> {
  late final PageController _pageController = PageController(
    viewportFraction: 0.72,
  );

  static const _cards = [
    _HomeModeCardData(
      title: 'Modo Pareja',
      mode: GameMode.couples,
      iconAsset: 'assets/logo-icon-couple-mode.png',
      backgroundAsset: 'assets/background-card-couple-mode-home.png',
      audienceText: '1 a 4 parejas',
      buttonText: 'Jugar en pareja',
      accentColor: AppColors.primary,
    ),
    _HomeModeCardData(
      title: 'Modo Amigos',
      mode: GameMode.friends,
      iconAsset: 'assets/logo-icon-friends-mode.png',
      backgroundAsset: 'assets/background-card-friends-mode-home.png',
      audienceText: '3 a 10 jugadores',
      buttonText: 'Jugar con amigos',
      accentColor: AppColors.secondary,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isPremium = ref.watch(premiumAccessProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final cardWidth = (constraints.maxWidth * 0.86).clamp(250.0, 312.0);
        final cardHeight = cardWidth * (678 / 478);

        return AnimatedBuilder(
          animation: _pageController,
          builder: (context, _) {
            final currentPage = _pageController.hasClients
                ? (_pageController.page ??
                      _pageController.initialPage.toDouble())
                : _pageController.initialPage.toDouble();

            return PageView.builder(
              controller: _pageController,
              itemCount: _cards.length,
              clipBehavior: Clip.none,
              itemBuilder: (context, index) {
                final distance = (currentPage - index).abs();
                final focus = (1 - distance).clamp(0.0, 1.0);
                final scale = 0.86 + (0.28 * focus);
                final yOffset = 20.0 - (32.0 * focus);
                final opacity = 0.42 + (0.58 * focus);
                final card = _cards[index];

                return Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.sm,
                  ),
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: Transform.translate(
                      offset: Offset(0, yOffset),
                      child: Transform.scale(
                        scale: scale,
                        alignment: Alignment.topCenter,
                        child: Opacity(
                          opacity: opacity,
                          child: SizedBox(
                            width: cardWidth,
                            height: cardHeight,
                            child: _HomeModeCard(
                              card: card,
                              isPremium: isPremium,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _HomeModeCardData {
  const _HomeModeCardData({
    required this.title,
    required this.mode,
    required this.iconAsset,
    required this.backgroundAsset,
    required this.audienceText,
    required this.buttonText,
    required this.accentColor,
  });

  final String title;
  final GameMode mode;
  final String iconAsset;
  final String backgroundAsset;
  final String audienceText;
  final String buttonText;
  final Color accentColor;
}

class _HomeModeCard extends StatelessWidget {
  const _HomeModeCard({required this.card, required this.isPremium});

  final _HomeModeCardData card;
  final bool isPremium;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(card.backgroundAsset),
          fit: BoxFit.fill,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 76, 36, 28),
        child: Column(
          children: [
            Image.asset(card.iconAsset, width: 124, fit: BoxFit.contain),
            const SizedBox(height: AppSpacing.lg),
            Text(
              card.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                height: 1.04,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Pensado para',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 16,
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              card.audienceText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                color: card.accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            App3dPillButton(
              label: card.buttonText,
              color: card.accentColor,
              depth: 3.5,
              height: 44,
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) =>
                        PlayerSetupPage(mode: card.mode, isPremium: isPremium),
                  ),
                );
              },
              textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                height: 1,
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
