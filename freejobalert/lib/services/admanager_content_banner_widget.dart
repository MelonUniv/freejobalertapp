import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'base_banner_ad_widget.dart';
import 'ad_helper.dart';

class AdManagerContentBannerWidget extends BaseBannerAdWidget {
  const AdManagerContentBannerWidget({super.key});

  @override
  State<AdManagerContentBannerWidget> createState() => _AdManagerContentBannerWidgetState();
}

class _AdManagerContentBannerWidgetState extends BaseBannerAdWidgetState<AdManagerContentBannerWidget> {
  @override
  String get adUnitId => AdHelper.adManagerContentBannerAdUnitId;

  @override
  AdSize get adSize => AdSize.banner;

  @override
  bool get enableAutoRefresh => false; // No auto-refresh for content banners

  @override
  Widget buildAdWidget(Widget adWidget) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          adWidget,
          const SizedBox(height: 4),
          Text(
            'Sponsored',
            style: TextStyle(
              fontSize: 9,
              color: Colors.grey[600],
              fontWeight: FontWeight.w300,
            ),
          ),
        ],
      ),
    );
  }
}
