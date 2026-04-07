import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:sharemeal/firebase_options.dart';
import 'package:sharemeal/models/app_state.dart';
import 'package:sharemeal/screens/splash_screen.dart';
import 'package:sharemeal/constants/app_theme.dart';
import 'package:sharemeal/services/local_notification_service.dart';
import 'package:sharemeal/services/background_notification_service.dart';
import 'package:sharemeal/screens/offline_game_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await LocalNotificationService.init();
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:          Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness:     Brightness.dark,
  ));
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const OfflineWrapper(child: ShareMealApp()),
    ),
  );
}

class ShareMealApp extends StatelessWidget {
  const ShareMealApp({super.key});

  @override
  Widget build(BuildContext context) {
    final appState = Provider.of<AppState>(context);
    return MaterialApp(
      title:                      'ShareMeal',
      debugShowCheckedModeBanner: false,
      theme:     AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home: const SplashScreen(),
    );
  }
}