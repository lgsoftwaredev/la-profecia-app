import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import '../../../game_mode_selection/domain/entities/game_mode.dart';
import '../../../player_setup/domain/entities/game_setup_models.dart';
import 'final_judgment_page.dart';

class FinalJudgmentIntroVideoPage extends StatefulWidget {
  const FinalJudgmentIntroVideoPage({
    required this.submission,
    required this.scoresByPlayerId,
    super.key,
  });

  final GameSetupSubmission submission;
  final Map<int, int> scoresByPlayerId;

  @override
  State<FinalJudgmentIntroVideoPage> createState() =>
      _FinalJudgmentIntroVideoPageState();
}

class _FinalJudgmentIntroVideoPageState
    extends State<FinalJudgmentIntroVideoPage> {
  VideoPlayerController? _controller;
  var _navigated = false;

  String get _videoAssetPath => widget.submission.mode.isFriends
      ? 'assets/videos/video-juicio-final-friends.mp4'
      : 'assets/videos/video-juicio-final-couple.mp4';

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
      _openFinalJudgmentPage();
    }
  }

  void _handleVideoProgress() {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }

    final duration = controller.value.duration;
    final position = controller.value.position;
    if (duration <= Duration.zero) {
      return;
    }

    if (position >= duration - const Duration(milliseconds: 120)) {
      _openFinalJudgmentPage();
    }
  }

  void _openFinalJudgmentPage() {
    if (!mounted || _navigated) {
      return;
    }
    _navigated = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => FinalJudgmentPage(
          submission: widget.submission,
          scoresByPlayerId: widget.scoresByPlayerId,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller?.removeListener(_handleVideoProgress);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    final isReady = controller != null && controller.value.isInitialized;

    return PopScope(
      canPop: false,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (isReady)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller.value.size.width,
                  height: controller.value.size.height,
                  child: VideoPlayer(controller),
                ),
              )
            else
              const Center(
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
