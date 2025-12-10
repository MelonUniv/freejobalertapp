import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'base_banner_ad_widget.dart';
import 'ad_helper.dart';

class ContainerBannerAdWidget extends BaseBannerAdWidget {
  final int position; // Container position (3, 6, or 9)

  const ContainerBannerAdWidget({
    super.key,
    required this.position,
  });

  @override
  State<ContainerBannerAdWidget> createState() => _ContainerBannerAdWidgetState();
}

class _ContainerBannerAdWidgetState extends BaseBannerAdWidgetState<ContainerBannerAdWidget> {
  // Only show ads at 3rd, 6th, and 9th positions
  static const List<int> adPositions = [3, 6, 9];

  @override
  String get adUnitId => AdHelper.bannerAdUnitId;

  @override
  AdSize get adSize => AdSize.banner;

  @override
  bool get enableAutoRefresh => false; // No auto-refresh for container ads

  @override
  Widget build(BuildContext context) {
    // Only show ad if position is in allowed positions
    if (!adPositions.contains(widget.position)) {
      return const SizedBox.shrink();
    }

    return super.build(context);
  }

  @override
  Widget buildAdWidget(Widget adWidget) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Advertisement',
            style: TextStyle(
              fontSize: 10,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 4),
          adWidget,
        ],
      ),
    );
  }
}
