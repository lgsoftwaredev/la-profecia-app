import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

import '../../features/premium/domain/services/entitlement_service.dart';
import '../config/app_environment.dart';

enum AdPlacement { roundSummaryToNextRound }

class AdService {
  AdService({required EntitlementService entitlementService})
    : _entitlementService = entitlementService;

  final EntitlementService _entitlementService;
  InterstitialAd? _interstitialAd;
  bool _loading = false;
  bool _initialized = false;

  Future<void> initialize() async {
    if (_initialized) {
      return;
    }
    _initialized = true;
    try {
      await MobileAds.instance.initialize();
      await _preloadInterstitial();
    } catch (_) {
      _initialized = false;
    }
  }

  Future<void> showInterstitialIfEligible(AdPlacement placement) async {
    if (_entitlementService.hasPremiumAccess()) {
      return;
    }
    if (!_isPlacementEnabled(placement)) {
      return;
    }
    final ad = _interstitialAd;
    if (ad == null) {
      await _preloadInterstitial();
      return;
    }
    final completer = Completer<void>();
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        ad.dispose();
        _interstitialAd = null;
        completer.complete();
        unawaited(_preloadInterstitial());
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        ad.dispose();
        _interstitialAd = null;
        completer.complete();
        unawaited(_preloadInterstitial());
      },
    );
    try {
      ad.show();
      await completer.future;
    } catch (_) {
      _interstitialAd = null;
      await _preloadInterstitial();
    }
  }

  Future<void> _preloadInterstitial() async {
    if (_loading || _interstitialAd != null) {
      return;
    }
    _loading = true;
    try {
      await InterstitialAd.load(
        adUnitId: _resolveInterstitialAdUnitId(),
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _interstitialAd?.dispose();
            _interstitialAd = ad;
            _loading = false;
          },
          onAdFailedToLoad: (error) {
            _loading = false;
          },
        ),
      );
    } catch (_) {
      _loading = false;
    }
  }

  bool _isPlacementEnabled(AdPlacement placement) {
    switch (placement) {
      case AdPlacement.roundSummaryToNextRound:
        return true;
    }
  }

  String _resolveInterstitialAdUnitId() {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return AppEnvironment.admobAndroidInterstitialId.isNotEmpty
          ? AppEnvironment.admobAndroidInterstitialId
          : 'ca-app-pub-3940256099942544/1033173712';
    }
    if (defaultTargetPlatform == TargetPlatform.iOS) {
      return AppEnvironment.admobIosInterstitialId.isNotEmpty
          ? AppEnvironment.admobIosInterstitialId
          : 'ca-app-pub-3940256099942544/4411468910';
    }
    return '';
  }
}
