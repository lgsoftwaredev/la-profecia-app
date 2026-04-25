import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/app_3d_pill_button.dart';
import '../../../premium/presentation/providers/premium_providers.dart';
import '../../domain/entities/game_mode.dart';
import '../../../player_setup/presentation/pages/player_setup_page.dart';

class HomeModeCarousel extends ConsumerStatefulWidget {
  const HomeModeCarousel({this.onModeChanged, super.key});

  final ValueChanged<GameMode>? onModeChanged;

  @override
  ConsumerState<HomeModeCarousel> createState() => _HomeModeCarouselState();
}

class _HomeModeCarouselState extends ConsumerState<HomeModeCarousel> {
  late final PageController _pageController = PageController(
    viewportFraction: 0.72,
  );
  var _lastReportedIndex = 0;

  static const _cards = [
    _HomeModeCardData(
      title: 'Modo Pareja',
      mode: GameMode.couples,
      iconAsset: 'assets/logo-icon-couple-mode.png',
      backgroundAsset: 'assets/background-card-couple-mode-home.png',
      audienceText: '1 pareja o más',
      buttonText: 'Jugar en pareja',
      accentColor: AppColors.primary,
    ),
    _HomeModeCardData(
      title: 'Modo Amigos',
      mode: GameMode.friends,
      iconAsset: 'assets/logo-icon-friends-mode.png',
      backgroundAsset: 'assets/background-card-friends-mode-home.png',
      audienceText: '2 a 12 jugadores',
      buttonText: 'Jugar con amigos',
      accentColor: AppColors.secondary,
    ),
  ];
  static const _baseCardHeightRatio = 678 / 478;
  static const _targetCardHeightRatio = 600 / 478;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }
      widget.onModeChanged?.call(_cards[_lastReportedIndex].mode);
    });
  }

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
        final cardHeight = cardWidth * _targetCardHeightRatio;
        final contentScale = (cardHeight / (cardWidth * _baseCardHeightRatio))
            .clamp(0.78, 1.0)
            .toDouble();

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
              onPageChanged: (index) {
                _lastReportedIndex = index;
                widget.onModeChanged?.call(_cards[index].mode);
              },
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
                              contentScale: contentScale,
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
  const _HomeModeCard({
    required this.card,
    required this.isPremium,
    required this.contentScale,
  });

  final _HomeModeCardData card;
  final bool isPremium;
  final double contentScale;

  @override
  Widget build(BuildContext context) {
    double s(double value) => value * contentScale;
    final buttonHeight = s(44).clamp(38.0, 44.0).toDouble();

    return DecoratedBox(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage(card.backgroundAsset),
          fit: BoxFit.fill,
        ),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(s(36), s(76), s(36), s(28)),
        child: Column(
          children: [
            Image.asset(card.iconAsset, width: s(124), fit: BoxFit.contain),
            SizedBox(height: s(AppSpacing.lg)),
            Text(
              card.title,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: s(28),
                fontWeight: FontWeight.w700,
                height: 1.04,
              ),
            ),
            SizedBox(height: s(14)),
            Text(
              'Pensado para',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: s(16),
                color: Colors.white.withValues(alpha: 0.78),
              ),
            ),
            SizedBox(height: s(4)),
            Text(
              card.audienceText,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontSize: s(18),
                color: card.accentColor,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              child: App3dPillButton(
                label: card.buttonText,
                color: card.accentColor,
                depth: s(3.5),
                height: buttonHeight,
                onTap: () {
                  Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          PlayerSetupPage(mode: card.mode, isPremium: isPremium),
                    ),
                  );
                },
                textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontSize: s(18),
                  fontWeight: FontWeight.w700,
                  height: 1,
                ),
              ),
            ),
            SizedBox(height: s(20)),
          ],
        ),
      ),
    );
  }
}
