import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../match_play/presentation/providers/match_providers.dart';
import '../../../player_setup/presentation/widgets/premium_glass_surface.dart';
import '../../../player_setup/presentation/widgets/level_card_frame.dart';
import '../../domain/entities/user_stats_summary.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({super.key});

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  var _authFlowStarted = false;

  @override
  void initState() {
    super.initState();
    if (!ref.read(isAuthenticatedProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openLoginIfNeeded();
      });
    }
  }

  Future<void> _openLoginIfNeeded() async {
    if (_authFlowStarted || ref.read(isAuthenticatedProvider) || !mounted) {
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
    if (didLogin == true && ref.read(isAuthenticatedProvider)) {
      return;
    }
    if (Navigator.of(context).canPop()) {
      Navigator.of(context).pop();
    }
  }

  Future<void> _logout() async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Cerrar sesion'),
          content: const Text('Estas seguro de que quieres cerrar sesion?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Cerrar sesion'),
            ),
          ],
        );
      },
    );
    if (shouldLogout != true || !mounted) {
      return;
    }

    await ref.read(authControllerProvider).signOut();
    if (!mounted) {
      return;
    }
    _openLoginIfNeeded();
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final session = ref.watch(authSessionProvider);
    final summaryAsync = ref.watch(matchStatsSummaryProvider);

    if (!isAuthenticated) {
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
                          _ProfileHeader(
                            displayName: session?.displayName ?? 'Jugador',
                            email: session?.email ?? 'sin-correo@local',
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          summaryAsync.when(
                            loading: () => const Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: AppSpacing.xl,
                              ),
                              child: CircularProgressIndicator(
                                strokeWidth: 2.4,
                              ),
                            ),
                            error: (error, stackTrace) => _ProfileDataError(
                              onRetry: () {
                                ref.invalidate(matchStatsSummaryProvider);
                              },
                            ),
                            data: (summary) => Column(
                              children: [
                                _StatsGrid(
                                  matchesPlayed: summary.matchesPlayed,
                                  accumulatedScore: summary.accumulatedScore,
                                  wins: summary.wins,
                                  losses: summary.losses,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                _HistoryCard(
                                  items: _toHistoryItems(summary.history),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          TextButton(
                            onPressed: _logout,
                            child: Text(
                              'Cerrar sesion',
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(color: Colors.white70),
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

  List<_HistoryItem> _toHistoryItems(List<GameHistoryItem> history) {
    return history
        .map((item) {
          final date = item.playedAt;
          final day = date.day.toString().padLeft(2, '0');
          final month = date.month.toString().padLeft(2, '0');
          final year = date.year.toString();
          final won = _didWinHistoryItem(item);
          return _HistoryItem(won: won, date: '$day/$month/$year');
        })
        .toList(growable: false);
  }

  bool _didWinHistoryItem(GameHistoryItem item) {
    final normalized = item.resultLabel.trim().toLowerCase();
    if (normalized.contains('perdid') ||
        normalized.contains('derrot') ||
        normalized == 'loss' ||
        normalized == 'lost') {
      return false;
    }
    if (normalized.contains('ganad') ||
        normalized.contains('victor') ||
        normalized == 'win' ||
        normalized == 'won') {
      return true;
    }
    if (item.scoreDelta > 0) {
      return true;
    }
    if (item.scoreDelta < 0) {
      return false;
    }
    return false;
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.displayName, required this.email});

  final String displayName;
  final String email;

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
                'Hola $displayName',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: Colors.white.withValues(alpha: 0.96),
                  fontWeight: FontWeight.w700,
                  fontSize: 44 * 0.62,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                email,
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
  const _StatsGrid({
    required this.matchesPlayed,
    required this.accumulatedScore,
    required this.wins,
    required this.losses,
  });

  final int matchesPlayed;
  final int accumulatedScore;
  final int wins;
  final int losses;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '$matchesPlayed',
                label: 'Partidas',
                valueColor: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                value: accumulatedScore >= 0
                    ? '+$accumulatedScore'
                    : '$accumulatedScore',
                label: 'Score',
                valueColor: const Color(0xFFFFA127),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                value: '$wins',
                label: 'Victorias',
                valueColor: const Color(0xFF8DFF68),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                value: '$losses',
                label: 'Derrotas',
                valueColor: const Color(0xFFFF4D49),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ProfileDataError extends StatelessWidget {
  const _ProfileDataError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'No se pudo cargar tu historial.',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            color: Colors.white.withValues(alpha: 0.8),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        TextButton(onPressed: onRetry, child: const Text('Reintentar')),
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
