import 'dart:async';

import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../../core/theme/app_spacing.dart';
import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../domain/entities/game_setup_models.dart';
import 'start_points_page.dart';

class PlayerSelectionIntroPage extends StatefulWidget {
  const PlayerSelectionIntroPage({required this.submission, super.key});

  final GameSetupSubmission submission;

  @override
  State<PlayerSelectionIntroPage> createState() =>
      _PlayerSelectionIntroPageState();
}

class _PlayerSelectionIntroPageState extends State<PlayerSelectionIntroPage> {
  VideoPlayerController? _controller;
  Timer? _autoContinueTimer;
  var _showSelectedPlayer = false;
  var _navigated = false;

  String get _videoAssetPath => widget.submission.mode.isFriends
      ? 'assets/videos/seleccion-jugador-amigos.mp4'
      : 'assets/videos/seleccion-jugador-parejas.mp4';

  Color get _modeAccent => widget.submission.mode.isFriends
      ? const Color(0xFF00B7FF)
      : const Color(0xFFE94494);

  PlayerConfig get _selectedPlayer => widget.submission.players.isNotEmpty
      ? widget.submission.players.first
      : const PlayerConfig(
          id: 1,
          name: 'Jugador 1',
          avatarAssetPath: 'assets/logo-icons-player-setup/friends/Icono 1.png',
        );

  String get _selectedPlayerName {
    final trimmed = _selectedPlayer.name.trim();
    if (trimmed.isNotEmpty) {
      return trimmed;
    }
    return 'Jugador ${_selectedPlayer.id}';
  }

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    final controller = VideoPlayerController.asset(_videoAssetPath);
    _controller = controller;
    controller.addListener(_handleVideoProgress);
    try {
      await controller.initialize();
      await controller.setLooping(false);
      await controller.play();
      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      _showSelectionResult();
    }
  }

  void _handleVideoProgress() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (_showSelectedPlayer) {
      return;
    }
    final ended =
        controller.value.duration > Duration.zero &&
        controller.value.position >= controller.value.duration;
    if (ended) {
      _showSelectionResult();
    }
  }

  void _showSelectionResult() {
    if (_showSelectedPlayer) {
      return;
    }
    setState(() {
      _showSelectedPlayer = true;
    });
    // _autoContinueTimer = Timer(
    //   const Duration(milliseconds: 3000),
    //   _openNextPage,
    // );
  }

  void _openNextPage() {
    if (!mounted || _navigated) {
      return;
    }
    _navigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => StartPointsPage(submission: widget.submission),
      ),
    );
  }

  @override
  void dispose() {
    _autoContinueTimer?.cancel();
    _controller?.removeListener(_handleVideoProgress);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _showSelectedPlayer ? _openNextPage : null,
        child: Stack(
          fit: StackFit.expand,
          children: [
            _VideoLayer(controller: _controller),
            if (_showSelectedPlayer) ...[
              TweenAnimationBuilder<double>(
                tween: Tween<double>(begin: 0, end: 1),
                duration: const Duration(milliseconds: 1000),
                curve: Curves.easeOutCubic,
                builder: (context, opacity, child) =>
                    Opacity(opacity: opacity, child: child),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.xxl * 1.8,
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 86,
                          height: 86,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: _modeAccent, width: 3),
                            boxShadow: [
                              BoxShadow(
                                color: _modeAccent.withValues(alpha: 0.28),
                                blurRadius: 16,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Image.asset(
                                _selectedPlayer.avatarAssetPath,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Text(
                          _selectedPlayerName,
                          textAlign: TextAlign.center,
                          style: Theme.of(context).textTheme.headlineMedium
                              ?.copyWith(
                                fontSize: 30,
                                fontWeight: FontWeight.w700,
                                color: Colors.white.withValues(alpha: 0.95),
                              ),
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.md,
                            vertical: AppSpacing.sm,
                          ),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(999),
                            color: const Color(
                              0xFF050A16,
                            ).withValues(alpha: 0.88),
                            border: Border.all(
                              color: _modeAccent.withValues(alpha: 0.74),
                            ),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star_rounded,
                                color: Color(0xFFFFD54A),
                                size: 24,
                              ),
                              const SizedBox(width: AppSpacing.xs),
                              Text(
                                '0 puntos',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Colors.white.withValues(
                                        alpha: 0.82,
                                      ),
                                      fontWeight: FontWeight.w500,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xxl),
                        const SizedBox(height: AppSpacing.xl),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _VideoLayer extends StatelessWidget {
  const _VideoLayer({required this.controller});

  final VideoPlayerController? controller;

  @override
  Widget build(BuildContext context) {
    final activeController = controller;
    if (activeController == null || !activeController.value.isInitialized) {
      return const ColoredBox(color: Colors.black);
    }
    final size = activeController.value.size;
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoPlayer(activeController),
      ),
    );
  }
}
