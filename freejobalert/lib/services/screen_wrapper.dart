import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'banner_ad_widget.dart';
import '../utils/app_logger.dart';

class ScreenWrapper extends StatefulWidget {
  final Widget child;
  final bool showBannerAd;
  final bool enableExitDialog;
  final VoidCallback? onNavigate;

  const ScreenWrapper({
    super.key,
    required this.child,
    this.showBannerAd = true,
    this.enableExitDialog = false,
    this.onNavigate,
  });

  @override
  State<ScreenWrapper> createState() => _ScreenWrapperState();
}

class _ScreenWrapperState extends State<ScreenWrapper> {
  // Removed auto-timer - ads should only show on user clicks, not automatically

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<bool> _onWillPop() async {
    if (!widget.enableExitDialog) {
      return true;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Exit App'),
        content: const Text('Are you sure you want to exit?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop(true);
              // Use method channel to exit app
              await _exitApp();
            },
            child: const Text('Yes'),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  Future<void> _exitApp() async {
    const platform = MethodChannel('com.freejobalert/exit');
    try {
      await platform.invokeMethod('exitApp');
    } on PlatformException catch (e) {
      AppLogger.error('Failed to exit app', e);
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content = widget.child;

    // Wrap with banner ad at bottom if enabled
    if (widget.showBannerAd) {
      content = Column(
        children: [
          Expanded(child: content),
          const BannerAdWidget(),
        ],
      );
    }

    // Wrap with PopScope for exit dialog if enabled
    if (widget.enableExitDialog) {
      content = PopScope(
        canPop: false,
        onPopInvokedWithResult: (bool didPop, dynamic result) async {
          if (didPop) return;

          final shouldPop = await _onWillPop();
          if (shouldPop && context.mounted) {
            Navigator.of(context).pop();
          }
        },
        child: content,
      );
    }

    return content;
  }
}
