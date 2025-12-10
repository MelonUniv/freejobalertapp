import 'dart:io';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdHelper {
  // Ad Unit IDs for Android
  static const String _androidBannerAdUnitId = 'ca-app-pub-8801321225174646/3598809519';

  // AdManager Ad Unit IDs (cross-platform)
  static const String _adManagerInterstitialAdUnitId = '/40776336/FJ_App_interestial';
  static const String _adManagerContentBannerAdUnitId = '/40776336/app-top-content-banner';

  // iOS uses same ad units
  static const String _iosBannerAdUnitId = 'ca-app-pub-8801321225174646/3598809519';

  static String get bannerAdUnitId {
    if (Platform.isAndroid) {
      return _androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return _iosBannerAdUnitId;
    }
    throw UnsupportedError('Unsupported platform');
  }

  static String get interstitialAdUnitId {
    // Using AdManager interstitial for both platforms
    return _adManagerInterstitialAdUnitId;
  }

  static String get adManagerContentBannerAdUnitId {
    return _adManagerContentBannerAdUnitId;
  }

  static Future<void> initialize() async {
    await MobileAds.instance.initialize();
  }
}
