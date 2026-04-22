import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/asset_looping_background_video.dart';

const _tutorialBottomReservedSpace = 190.0;

class TutorialBackground extends StatelessWidget {
  const TutorialBackground({
    this.assetPath,
    this.videoAssetPath,
    required this.child,
    this.bottomReservedSpace = _tutorialBottomReservedSpace,
    super.key,
  }) : assert(
         assetPath != null || videoAssetPath != null,
         'Provide assetPath or videoAssetPath.',
       );

  final String? assetPath;
  final String? videoAssetPath;
  final Widget child;
  final double bottomReservedSpace;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        if (videoAssetPath != null)
          AssetLoopingBackgroundVideo(
            assetPath: videoAssetPath!,
            fallbackAssetPath: assetPath,
          )
        else
          Image.asset(assetPath!, fit: BoxFit.cover),
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                AppColors.backgroundOverlayTop,
                AppColors.backgroundOverlayBottom,
              ],
            ),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: EdgeInsets.only(bottom: bottomReservedSpace),
            child: child,
          ),
        ),
      ],
    );
  }
}

class TutorialIconSquare extends StatelessWidget {
  const TutorialIconSquare({
    required this.iconAsset,
    this.useCleanInframundo = false,
    this.backgroundColor,
    super.key,
  });

  final String iconAsset;
  final bool useCleanInframundo;
  final Color? backgroundColor;

  @override
  Widget build(BuildContext context) {
    final isInframundo =
        useCleanInframundo && iconAsset.contains('inframundo-icon-logo');

    return Container(
      width: 46,
      height: 46,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
      ),
      child: isInframundo
          ? Text(
              '😈',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontSize: 31,
                color: const Color(0xFFC246FF),
                fontWeight: FontWeight.w700,
              ),
            )
          : Image.asset(iconAsset, width: 38, height: 38, fit: BoxFit.contain),
    );
  }
}
