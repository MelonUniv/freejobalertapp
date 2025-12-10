import 'dart:async';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'ad_helper.dart';
import '../utils/app_logger.dart';

class AdManager {
  static final AdManager _instance = AdManager._internal();
  factory AdManager() => _instance;
  AdManager._internal();

  AdManagerInterstitialAd? _interstitialAd;
  bool _isInterstitialAdReady = false;
  DateTime? _lastAdShowTime;
  int _clickCount = 0;
  bool _firstInteractionDone = false;

  // Ad interval (3 minutes)
  static const Duration adInterval = Duration(minutes: 3);

  // Initialize and load interstitial ad
  void loadInterstitialAd() {
    AdManagerInterstitialAd.load(
      adUnitId: AdHelper.interstitialAdUnitId,
      request: const AdManagerAdRequest(),
      adLoadCallback: AdManagerInterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitialAd = ad;
          _isInterstitialAdReady = true;
          AppLogger.success('Interstitial ad loaded');

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              AppLogger.info('Interstitial ad dismissed');
              ad.dispose();
              _isInterstitialAdReady = false;
              // Preload next ad
              loadInterstitialAd();
            },
            onAdFailedToShowFullScreenContent: (ad, error) {
              AppLogger.error('Failed to show interstitial ad', error);
              ad.dispose();
              _isInterstitialAdReady = false;
              // Preload next ad
              loadInterstitialAd();
            },
          );
        },
        onAdFailedToLoad: (error) {
          AppLogger.error('Failed to load interstitial ad', error);
          _isInterstitialAdReady = false;
        },
      ),
    );
  }

  // Show interstitial ad based on conditions
  void showInterstitialAd({bool isFirstClick = false}) {
    if (isFirstClick) {
      _firstInteractionDone = true;
      _clickCount++;
      return; // Don't show ad on first click
    }

    _clickCount++;

    if (_isInterstitialAdReady && _interstitialAd != null && shouldShowAd()) {
      _interstitialAd!.show();
      _lastAdShowTime = DateTime.now();
    } else {
      if (!_isInterstitialAdReady) {
        AppLogger.warning('Interstitial ad not ready');
        // Try to load it for next time
        loadInterstitialAd();
      }
    }
  }

  // Check if ad should be shown based on time
  bool shouldShowAd() {
    if (_lastAdShowTime == null) {
      return true; // First ad can be shown
    }

    final timeSinceLastAd = DateTime.now().difference(_lastAdShowTime!);
    return timeSinceLastAd >= adInterval;
  }

  // Check if this is first interaction
  bool get isFirstInteraction => !_firstInteractionDone;

  // Dispose ad
  void dispose() {
    _interstitialAd?.dispose();
  }

  // Get click count
  int get clickCount => _clickCount;

  // Reset click count
  void resetClickCount() {
    _clickCount = 0;
  }
}
