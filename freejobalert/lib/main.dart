import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'firebase_options.dart';
import 'screens/splash_screen.dart';
import 'services/ad_helper.dart';
import 'services/ad_manager.dart';
import 'utils/app_logger.dart';

// Global navigator key for navigation from anywhere in the app
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

// Background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  AppLogger.firebase('Handling background message: ${message.messageId}');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    ).timeout(
      const Duration(seconds: 5),
      onTimeout: () {
        AppLogger.error('Firebase initialization timed out');
        throw Exception('Firebase initialization failed');
      },
    );

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    AppLogger.success('Firebase Core initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize Firebase', e, stackTrace);
  }

  // Google Mobile Ads initialization
  try {
    await AdHelper.initialize().timeout(
      const Duration(seconds: 3),
      onTimeout: () {
        AppLogger.warning('Ad initialization timed out');
      },
    );
    Future.microtask(() => AdManager().loadInterstitialAd());
    AppLogger.success('Ads initialized successfully');
  } catch (e, stackTrace) {
    AppLogger.error('Failed to initialize Ads', e, stackTrace);
  }

  // Start app after critical initialization
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Free Job Alert',
      debugShowCheckedModeBanner: false,
      navigatorKey: navigatorKey,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: false,
          elevation: 1,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}