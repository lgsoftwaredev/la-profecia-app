import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class AssetLoopingBackgroundVideo extends StatefulWidget {
  const AssetLoopingBackgroundVideo({
    required this.assetPath,
    this.fallbackAssetPath,
    super.key,
  });

  final String assetPath;
  final String? fallbackAssetPath;

  @override
  State<AssetLoopingBackgroundVideo> createState() =>
      _AssetLoopingBackgroundVideoState();
}

class _AssetLoopingBackgroundVideoState
    extends State<AssetLoopingBackgroundVideo>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initController();
  }

  Future<void> _initController() async {
    final controller = VideoPlayerController.asset(widget.assetPath);
    _controller = controller;

    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(0);
      await controller.play();
      if (mounted) {
        setState(() {});
      }
    } catch (_) {}
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.resumed) {
      controller.play();
      return;
    }
    if (state == AppLifecycleState.inactive ||
        state == AppLifecycleState.hidden ||
        state == AppLifecycleState.paused) {
      controller.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      if (widget.fallbackAssetPath != null) {
        return Image.asset(widget.fallbackAssetPath!, fit: BoxFit.cover);
      }
      return const ColoredBox(color: Colors.black);
    }

    final size = controller.value.size;
    return FittedBox(
      fit: BoxFit.cover,
      child: SizedBox(
        width: size.width,
        height: size.height,
        child: VideoPlayer(controller),
      ),
    );
  }
}
