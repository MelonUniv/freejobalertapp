import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../utils/app_logger.dart';

/// Base class for all banner ad widgets to reduce code duplication
abstract class BaseBannerAdWidget extends StatefulWidget {
  const BaseBannerAdWidget({super.key});

  @override
  State<BaseBannerAdWidget> createState();
}

abstract class BaseBannerAdWidgetState<T extends BaseBannerAdWidget> extends State<T> {
  BannerAd? _bannerAd;
  bool _isAdLoaded = false;
  Timer? _refreshTimer;

  /// Subclasses must provide the ad unit ID
  String get adUnitId;

  /// Subclasses can override the ad size (default: AdSize.banner)
  AdSize get adSize => AdSize.banner;

  /// Subclasses can override whether auto-refresh is enabled
  bool get enableAutoRefresh => false;

  /// Subclasses can override the refresh interval (default: 60 seconds)
  Duration get refreshInterval => const Duration(seconds: 60);

  /// Subclasses can override retry delay (default: 30 seconds)
  Duration get retryDelay => const Duration(seconds: 30);

  @override
  void initState() {
    super.initState();
    _loadAd();

    if (enableAutoRefresh) {
      _setupAutoRefresh();
    }
  }

  /// Load the banner ad
  void _loadAd() {
    if (adUnitId.isEmpty) {
      AppLogger.warning('Ad unit ID is empty, skipping ad load', '[BannerAd]');
      return;
    }

    AppLogger.info('Loading banner ad: $adUnitId', '[BannerAd]');

    _bannerAd = BannerAd(
      adUnitId: adUnitId,
      size: adSize,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          AppLogger.success('Banner ad loaded: $adUnitId', '[BannerAd]');
          if (mounted) {
            setState(() {
              _isAdLoaded = true;
            });
          }
        },
        onAdFailedToLoad: (ad, error) {
          AppLogger.error('Banner ad failed to load: $adUnitId', error, null, '[BannerAd]');
          ad.dispose();

          // Retry loading after delay
          if (mounted) {
            Future.delayed(retryDelay, () {
              if (mounted) {
                _loadAd();
              }
            });
          }
        },
        onAdOpened: (ad) {
          AppLogger.info('Banner ad opened: $adUnitId', '[BannerAd]');
        },
        onAdClosed: (ad) {
          AppLogger.info('Banner ad closed: $adUnitId', '[BannerAd]');
        },
        onAdImpression: (ad) {
          AppLogger.info('Banner ad impression: $adUnitId', '[BannerAd]');
        },
        onAdClicked: (ad) {
          AppLogger.info('Banner ad clicked: $adUnitId', '[BannerAd]');
        },
      ),
    );

    _bannerAd?.load();
  }

  /// Setup auto-refresh for the ad
  void _setupAutoRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(refreshInterval, (timer) {
      if (mounted) {
        AppLogger.info('Auto-refreshing banner ad: $adUnitId', '[BannerAd]');
        _refreshAd();
      }
    });
  }

  /// Refresh the banner ad
  void _refreshAd() {
    _bannerAd?.dispose();
    _isAdLoaded = false;
    _loadAd();
  }

  /// Subclasses can override to customize the widget wrapper
  Widget buildAdWidget(Widget adWidget) {
    return adWidget;
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null || !_isAdLoaded) {
      return const SizedBox.shrink();
    }

    return buildAdWidget(
      SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _refreshTimer = null;
    _bannerAd?.dispose();
    _bannerAd = null;
    AppLogger.info('Banner ad disposed: $adUnitId', '[BannerAd]');
    super.dispose();
  }
}
