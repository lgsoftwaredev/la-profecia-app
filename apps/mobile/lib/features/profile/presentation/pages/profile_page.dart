import 'package:flutter/material.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/global_bottom_menu.dart';
import '../../../auth/presentation/controllers/auth_session_store.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../game_mode_selection/presentation/pages/home_page.dart';
import '../../../player_setup/presentation/widgets/premium_glass_surface.dart';
import '../../../player_setup/presentation/widgets/level_card_frame.dart';
import '../../../premium/presentation/pages/premium_menu_page.dart';
import '../../../settings/presentation/pages/settings_page.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  var _bottomMenuItem = GlobalBottomMenuItem.profile;
  var _sessionReady = AuthSessionStore.hasSession;
  var _authFlowStarted = false;

  static const _history = <_HistoryItem>[
    _HistoryItem(won: true, date: '21/01/2026'),
    _HistoryItem(won: true, date: '21/01/2026'),
    _HistoryItem(won: false, date: '21/01/2026'),
    _HistoryItem(won: false, date: '21/01/2026'),
    _HistoryItem(won: true, date: '21/01/2026'),
    _HistoryItem(won: false, date: '21/01/2026'),
  ];

  @override
  void initState() {
    super.initState();
    if (!_sessionReady) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openLoginIfNeeded();
      });
    }
  }

  Future<void> _openLoginIfNeeded() async {
    if (_authFlowStarted || _sessionReady || !mounted) {
      return;
    }
    _authFlowStarted = true;
    final didLogin = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute<bool>(builder: (_) => const LoginPage()));
    _authFlowStarted = false;
    if (!mounted) {
      return;
    }
    if (didLogin == true && AuthSessionStore.hasSession) {
      setState(() {
        _sessionReady = true;
      });
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

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

  @override
  Widget build(BuildContext context) {
    if (!_sessionReady) {
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
            const Center(child: CircularProgressIndicator(strokeWidth: 2.4)),
          ],
        ),
      );
    }

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
                center: Alignment(-0.7, -0.95),
                radius: 0.95,
                colors: [Color(0x6638578A), Colors.transparent],
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
                        'Profile',
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
                          const SizedBox(height: AppSpacing.sm),
                          const _ProfileHeader(),
                          const SizedBox(height: AppSpacing.lg),
                          const _StatsGrid(),
                          const SizedBox(height: AppSpacing.md),
                          _HistoryCard(items: _history),
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

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 76,
          height: 76,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.30),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipOval(
            child: Image.asset(
              'assets/logo-icon-user-profile.png',
              fit: BoxFit.cover,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hola Miguel!',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.96),
                  fontWeight: FontWeight.w700,
                  fontSize: 44 * 0.62,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'miguel.castro@gmail.com',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.55),
                  fontWeight: FontWeight.w500,
                  fontSize: 29 * 0.50,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: const [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '12',
                label: 'Partidas',
                valueColor: Colors.white,
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                value: '+125',
                label: 'Score',
                valueColor: Color(0xFFFFA127),
              ),
            ),
          ],
        ),
        SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '7',
                label: 'Victorias',
                valueColor: Color(0xFF8DFF68),
              ),
            ),
            SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                value: '5',
                label: 'Derrotas',
                valueColor: Color(0xFFFF4D49),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  const _StatCard({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    final glow = valueColor.withValues(alpha: 0.20);

    return LevelCardFrame(
      height: 128,
      borderRadius: 18,
      borderColor: valueColor.withValues(alpha: 0.85),
      onTap: () {},
      enabled: false,
      contentPadding: EdgeInsets.zero,
      child: PremiumGlassSurface(
        borderRadius: BorderRadius.circular(16),
        gradientColors: [
          const Color(0xFF25283A).withValues(alpha: 0.85),
          const Color(0xFF0A0E16).withValues(alpha: 0.94),
        ],
        borderColor: Colors.white.withValues(alpha: 0.17),
        innerBorderColor: Colors.white.withValues(alpha: 0.05),
        outerShadows: [
          BoxShadow(color: glow, blurRadius: 22, spreadRadius: -2),
        ],
        topHighlightOpacity: 0.10,
        bottomShadeOpacity: 0.16,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            AppSpacing.sm,
          ),
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: valueColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 50 * 0.66,
                    ),
                  ),
                ),
              ),
              PremiumGlassSurface(
                height: 40,
                borderRadius: BorderRadius.circular(10),
                gradientColors: [
                  const Color(0xFF11161F).withValues(alpha: 0.92),
                  const Color(0xFF0A0D13).withValues(alpha: 0.96),
                ],
                borderColor: Colors.white.withValues(alpha: 0.14),
                innerBorderColor: Colors.white.withValues(alpha: 0.05),
                topHighlightOpacity: 0.09,
                bottomShadeOpacity: 0.12,
                child: Center(
                  child: Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w500,
                      fontSize: 28 * 0.52,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.items});

  final List<_HistoryItem> items;

  @override
  Widget build(BuildContext context) {
    final rowsHeight =
        (items.length * 58) +
        ((items.isEmpty ? 0 : items.length - 1) * AppSpacing.xs);
    final cardHeight = 104.0 + rowsHeight;

    return PremiumGlassSurface(
      height: cardHeight,
      borderRadius: BorderRadius.circular(18),
      gradientColors: [
        const Color(0xFF232833).withValues(alpha: 0.82),
        const Color(0xFF0A0D14).withValues(alpha: 0.95),
      ],
      borderColor: Colors.white.withValues(alpha: 0.18),
      innerBorderColor: Colors.white.withValues(alpha: 0.05),
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.sm,
        AppSpacing.md,
      ),
      topHighlightOpacity: 0.10,
      bottomShadeOpacity: 0.14,
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Historial',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
                  fontSize: 34 * 0.55,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 28,
                color: Colors.white.withValues(alpha: 0.65),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          for (var index = 0; index < items.length; index++) ...[
            _HistoryRow(item: items[index]),
            if (index != items.length - 1)
              const SizedBox(height: AppSpacing.xs),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Ver mas',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.80),
              fontWeight: FontWeight.w500,
              fontSize: 26 * 0.53,
            ),
          ),
        ],
      ),
    );
  }
}

class _HistoryRow extends StatelessWidget {
  const _HistoryRow({required this.item});

  final _HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final accent = item.won ? const Color(0xFF6DFF64) : const Color(0xFFFF4A41);

    return PremiumGlassSurface(
      height: 58,
      borderRadius: BorderRadius.circular(10),
      gradientColors: [
        const Color(0xFF10151E).withValues(alpha: 0.94),
        const Color(0xFF080B12).withValues(alpha: 0.96),
      ],
      borderColor: accent.withValues(alpha: 0.68),
      innerBorderColor: Colors.white.withValues(alpha: 0.05),
      topHighlightOpacity: 0.08,
      bottomShadeOpacity: 0.12,
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.won ? 'Ganada' : 'Perdida',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: accent,
                    fontWeight: FontWeight.w700,
                    fontSize: 30 * 0.53,
                  ),
                ),
                const SizedBox(height: 1),
                Text(
                  item.date,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.45),
                    fontWeight: FontWeight.w500,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 76,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: const BorderRadius.horizontal(
                left: Radius.circular(24),
                right: Radius.circular(8),
              ),
            ),
            child: Icon(
              item.won ? Icons.check_rounded : Icons.close_rounded,
              color: accent,
              size: 25,
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

class _HistoryItem {
  const _HistoryItem({required this.won, required this.date});

  final bool won;
  final String date;
}
