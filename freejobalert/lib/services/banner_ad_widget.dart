import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'base_banner_ad_widget.dart';
import 'ad_helper.dart';

class BannerAdWidget extends BaseBannerAdWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends BaseBannerAdWidgetState<BannerAdWidget> {
  @override
  String get adUnitId => AdHelper.bannerAdUnitId;

  @override
  AdSize get adSize => AdSize.banner;

  @override
  bool get enableAutoRefresh => true;

  @override
  Duration get refreshInterval => const Duration(seconds: 60);

  @override
  Widget buildAdWidget(Widget adWidget) {
    return Container(
      width: adWidget.key is ValueKey ? (adWidget.key as ValueKey).value['width'] : adSize.width.toDouble(),
      height: adWidget.key is ValueKey ? (adWidget.key as ValueKey).value['height'] : adSize.height.toDouble(),
      alignment: Alignment.center,
      child: adWidget,
    );
  }
}
