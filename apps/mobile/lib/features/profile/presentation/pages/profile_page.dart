import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../app/providers/app_providers.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/widgets/global_bottom_menu.dart';
import '../../../auth/presentation/pages/login_page.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../game_mode_selection/presentation/pages/home_page.dart';
import '../../../match_play/presentation/providers/match_providers.dart';
import '../../../premium/presentation/pages/premium_menu_page.dart';
import '../../../premium/presentation/providers/premium_providers.dart';
import '../../../settings/presentation/pages/settings_page.dart';
import '../../domain/entities/editable_profile.dart';
import '../../domain/entities/user_stats_summary.dart';
import '../providers/profile_providers.dart';
import '../widgets/editable_profile_dialog.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({
    this.showBottomMenu = true,
    this.isTabActive = true,
    this.onGlobalMenuRequested,
    super.key,
  });

  final bool showBottomMenu;
  final bool isTabActive;
  final ValueChanged<GlobalBottomMenuItem>? onGlobalMenuRequested;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  var _authFlowStarted = false;

  Future<void> _onBottomMenuItemSelected(GlobalBottomMenuItem item) async {
    if (widget.onGlobalMenuRequested != null) {
      widget.onGlobalMenuRequested!(item);
      return;
    }

    if (item == GlobalBottomMenuItem.profile) {
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

    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(builder: (_) => const SettingsPage()),
    );
  }

  @override
  void initState() {
    super.initState();
    if (widget.isTabActive && !ref.read(isAuthenticatedProvider)) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _openLoginIfNeeded();
      });
    }
  }

  @override
  void didUpdateWidget(covariant ProfilePage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!oldWidget.isTabActive &&
        widget.isTabActive &&
        !ref.read(isAuthenticatedProvider)) {
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
    if (widget.onGlobalMenuRequested != null) {
      widget.onGlobalMenuRequested!(GlobalBottomMenuItem.home);
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

  Future<void> _openEditProfile({
    required bool isPremium,
    required EditableProfile initialProfile,
  }) async {
    if (!isPremium) {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const PremiumMenuPage()));
      return;
    }

    final updated = await showDialog<EditableProfile>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.72),
      builder: (dialogContext) {
        final size = MediaQuery.sizeOf(dialogContext);
        return Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 620,
              maxHeight: size.height * 0.60,
            ),
            child: Dialog(
              alignment: Alignment.center,
              backgroundColor: Colors.transparent,
              elevation: 0,
              insetPadding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.lg,
              ),
              child: EditableProfileDialog(
                initialProfile: initialProfile,
                title: 'Editar mi perfil',
                avatarAssetPath: 'assets/logo-icon-user-profile.png',
                onSave:
                    ({
                      required String displayName,
                      required ProfileIdentity identity,
                      required ProfileAttraction attraction,
                    }) async {
                      final profile = await ref
                          .read(profileServiceProvider)
                          .updateCurrentProfile(
                            displayName: displayName,
                            identity: identity,
                            attraction: attraction,
                          );
                      return profile;
                    },
              ),
            ),
          ),
        );
      },
    );

    if (updated != null) {
      ref.invalidate(editableProfileProvider);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Perfil actualizado.')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isAuthenticated = ref.watch(isAuthenticatedProvider);
    final isPremium = ref.watch(premiumAccessProvider);
    final session = ref.watch(authSessionProvider);
    final summaryAsync = ref.watch(matchStatsSummaryProvider);
    final profileAsync = ref.watch(editableProfileProvider);

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
        bottomNavigationBar: widget.showBottomMenu
            ? GlobalBottomMenu(
                currentItem: GlobalBottomMenuItem.profile,
                onItemSelected: _onBottomMenuItemSelected,
              )
            : null,
      );
    }

    final fallbackName = session?.displayName?.trim();
    final defaultName = fallbackName != null && fallbackName.isNotEmpty
        ? fallbackName
        : 'Jugador';

    final editableProfile =
        profileAsync.valueOrNull ??
        EditableProfile(
          displayName: defaultName,
          identity: null,
          attraction: null,
        );

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
              child: SingleChildScrollView(
                padding: const EdgeInsets.only(bottom: 170, top: AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _ProfileHeader(
                      displayName: editableProfile.displayName,
                      email: session?.email ?? 'sin-correo@local',
                      identityLabel:
                          editableProfile.identity?.label ?? 'No disponible',
                      attractionLabel:
                          editableProfile.attraction?.label ?? 'No disponible',
                      onEditTap: () => _openEditProfile(
                        isPremium: isPremium,
                        initialProfile: editableProfile,
                      ),
                    ),
                    if (profileAsync.hasError) ...[
                      const SizedBox(height: AppSpacing.sm),
                      _InlineErrorText(
                        message:
                            'No se pudo cargar todo tu perfil. Puedes reintentar.',
                        onRetry: () => ref.invalidate(editableProfileProvider),
                      ),
                    ],
                    const SizedBox(height: AppSpacing.lg),
                    Row(
                      children: [
                        Icon(
                          Icons.show_chart_rounded,
                          color: Colors.white.withValues(alpha: 0.82),
                          size: 20,
                        ),
                        const SizedBox(width: AppSpacing.xs),
                        Text(
                          'Tus estadisticas',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.95),
                                fontWeight: FontWeight.w700,
                                fontSize: 33 * 0.56,
                              ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    summaryAsync.when(
                      loading: () => const Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Center(
                          child: CircularProgressIndicator(strokeWidth: 2.4),
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
                          const SizedBox(height: AppSpacing.lg),
                          _HistoryCard(items: _toHistoryItems(summary.history)),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),
                    Center(
                      child: TextButton(
                        onPressed: _logout,
                        child: Text(
                          'Cerrar sesion',
                          style: Theme.of(context).textTheme.titleMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.88),
                                fontWeight: FontWeight.w600,
                              ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: widget.showBottomMenu
          ? GlobalBottomMenu(
              currentItem: GlobalBottomMenuItem.profile,
              onItemSelected: _onBottomMenuItemSelected,
            )
          : null,
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
          return _HistoryItem(
            won: won,
            date: '$day/$month/$year',
            headline: _resolveHeadline(item, won: won),
          );
        })
        .toList(growable: false);
  }

  String _resolveHeadline(GameHistoryItem item, {required bool won}) {
    final direct = item.headline?.trim();
    if (direct != null && direct.isNotEmpty) {
      return direct;
    }
    return won ? 'Ganada la partida' : 'Perdida la partida';
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

class _InlineErrorText extends StatelessWidget {
  const _InlineErrorText({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ),
        TextButton(onPressed: onRetry, child: const Text('Reintentar')),
      ],
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({
    required this.displayName,
    required this.email,
    required this.identityLabel,
    required this.attractionLabel,
    required this.onEditTap,
  });

  final String displayName;
  final String email;
  final String identityLabel;
  final String attractionLabel;
  final VoidCallback onEditTap;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 88,
          height: 88,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white.withValues(alpha: 0.24)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.34),
                blurRadius: 20,
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
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Text(
                      'Hola $displayName!',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: Colors.white.withValues(alpha: 0.97),
                            fontWeight: FontWeight.w700,
                            fontSize: 45 * 0.62,
                          ),
                    ),
                  ),
                  _EditButton(onTap: onEditTap),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                email,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.54),
                  fontWeight: FontWeight.w500,
                  fontSize: 28 * 0.50,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.person_rounded,
                      text: identityLabel,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: _InfoChip(
                      icon: Icons.favorite_rounded,
                      text: attractionLabel,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 34,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF121625).withValues(alpha: 0.88),
            const Color(0xFF0A0D17).withValues(alpha: 0.94),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.13)),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppSpacing.sm),
          Icon(icon, color: Colors.white.withValues(alpha: 0.66), size: 17),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white.withValues(alpha: 0.70),
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
        ],
      ),
    );
  }
}

class _EditButton extends StatelessWidget {
  const _EditButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 30,
      child: OutlinedButton.icon(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          side: BorderSide(color: Colors.white.withValues(alpha: 0.55)),
          foregroundColor: Colors.white.withValues(alpha: 0.95),
          shape: const StadiumBorder(),
          padding: const EdgeInsets.symmetric(horizontal: 11),
          visualDensity: VisualDensity.compact,
        ),
        icon: const Icon(Icons.edit_outlined, size: 14),
        label: const Text('Editar'),
      ),
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
              child: _StatsMetricCard(
                value: '$matchesPlayed',
                label: 'Partidas',
                valueColor: Colors.white,
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _StatsMetricCard(
                value: accumulatedScore >= 0
                    ? '+$accumulatedScore'
                    : '$accumulatedScore',
                label: 'Puntaje',
                valueColor: const Color(0xFFFFA127),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        Row(
          children: [
            Expanded(
              child: _StatsMetricCard(
                value: '$wins',
                label: 'Victorias',
                valueColor: const Color(0xFF8DFF68),
              ),
            ),
            const SizedBox(width: AppSpacing.lg),
            Expanded(
              child: _StatsMetricCard(
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

class _StatsMetricCard extends StatelessWidget {
  const _StatsMetricCard({
    required this.value,
    required this.label,
    required this.valueColor,
  });

  final String value;
  final String label;
  final Color valueColor;

  @override
  Widget build(BuildContext context) {
    const radius = 26.0;
    final accentColor = _accentColor();
    final accentCenter = _accentCenter();

    return Container(
      height: 138,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(radius),
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            const Color(0xFF24283A).withValues(alpha: 0.86),
            const Color(0xFF0A0D15).withValues(alpha: 0.96),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.09)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.45),
            blurRadius: 24,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: accentColor.withValues(alpha: 0.18),
            blurRadius: 20,
            spreadRadius: -7,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.84),
                  radius: 0.78,
                  colors: [
                    Colors.white.withValues(alpha: 0.17),
                    Colors.white.withValues(alpha: 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: accentCenter,
                  radius: 0.95,
                  colors: [
                    accentColor.withValues(alpha: 0.22),
                    accentColor.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    const Color(0xFF070A12).withValues(alpha: 0.24),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.md,
                AppSpacing.sm,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    value,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      color: valueColor,
                      fontWeight: FontWeight.w700,
                      fontSize: 36,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    label,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white.withValues(alpha: 0.88),
                      fontWeight: FontWeight.w500,
                      fontSize: 28 * 0.52,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _accentColor() {
    if (valueColor.toARGB32() == Colors.white.toARGB32()) {
      return const Color(0xFFC6CEE8);
    }
    return valueColor;
  }

  Alignment _accentCenter() {
    final rgb = valueColor.toARGB32() & 0x00FFFFFF;
    if (rgb == 0x00FFA127) {
      return const Alignment(0.74, -0.78);
    }
    if (rgb == 0x008DFF68) {
      return const Alignment(-0.72, -0.78);
    }
    if (rgb == 0x00FF4D49) {
      return const Alignment(0.72, -0.78);
    }
    return const Alignment(0, -0.84);
  }
}

class _HistoryCard extends StatelessWidget {
  const _HistoryCard({required this.items});

  final List<_HistoryItem> items;

  @override
  Widget build(BuildContext context) {
    final rowsHeight = items.isEmpty
        ? 56.0
        : (items.length * 72) +
              ((items.length > 1 ? items.length - 1 : 0) * AppSpacing.sm);
    final cardHeight = 84.0 + rowsHeight + 42;

    return Container(
      height: cardHeight,
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            const Color(0xFF252A36).withValues(alpha: 0.84),
            const Color(0xFF090C13).withValues(alpha: 0.96),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.42),
            blurRadius: 30,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Historial',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white.withValues(alpha: 0.95),
                  fontWeight: FontWeight.w700,
                  fontSize: 34 * 0.57,
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
          if (items.isEmpty)
            Center(
              child: Text(
                'Aun no hay partidas registradas.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.white.withValues(alpha: 0.58),
                ),
              ),
            )
          else
            for (var index = 0; index < items.length; index++) ...[
              _HistoryResultTile(item: items[index]),
              if (index != items.length - 1)
                const SizedBox(height: AppSpacing.sm),
            ],
          const SizedBox(height: AppSpacing.md),
        ],
      ),
    );
  }
}

class _HistoryResultTile extends StatelessWidget {
  const _HistoryResultTile({required this.item});

  final _HistoryItem item;

  @override
  Widget build(BuildContext context) {
    final accent = item.won ? const Color(0xFF8CFF6D) : const Color(0xFFFF4A41);
    final parts = item.headline.trim().split(RegExp(r'\s+'));
    final firstWord = parts.isEmpty ? item.headline : parts.first;
    final rest = parts.length > 1
        ? item.headline.substring(firstWord.length)
        : '';

    return Container(
      height: 72,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.10),
            accent.withValues(alpha: 0.64),
          ],
          stops: const [0, 0.6, 1],
        ),
        boxShadow: [
          BoxShadow(
            color: accent.withValues(alpha: 0.02),
            blurRadius: 8,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(1),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(21),
          child: Stack(
            fit: StackFit.expand,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      const Color(0xFF07090E).withValues(alpha: 0.98),
                      const Color(0xFF090C12).withValues(alpha: 0.78),
                      const Color(0xFF090C12).withValues(alpha: 0.58),
                      accent.withValues(alpha: 0.24),
                    ],
                    stops: const [0.5, 1, 0.53, 1],
                  ),
                ),
              ),
              DecoratedBox(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    center: const Alignment(1.05, 0),
                    radius: 0.9,
                    colors: [
                      accent.withValues(alpha: 0.20),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
              Row(
                children: [
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text.rich(
                          TextSpan(
                            children: [
                              TextSpan(
                                text: firstWord,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: accent,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 30 * 0.52,
                                    ),
                              ),
                              TextSpan(
                                text: rest,
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.92,
                                      ),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 30 * 0.52,
                                    ),
                              ),
                            ],
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 1),
                        Text(
                          item.date,
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(
                                color: Colors.white.withValues(alpha: 0.42),
                                fontWeight: FontWeight.w500,
                                fontSize: 13,
                              ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 70,
                    child: Icon(
                      item.won ? Icons.check_rounded : Icons.close_rounded,
                      color: accent,
                      size: 28,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HistoryItem {
  const _HistoryItem({
    required this.won,
    required this.date,
    required this.headline,
  });

  final bool won;
  final String date;
  final String headline;
}
