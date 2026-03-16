import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'models/app_state.dart';
import 'screens/login_screen.dart';
import 'constants/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // White icons on the dark sage hero bar
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor:          Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    statusBarBrightness:     Brightness.dark, // iOS
  ));

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const ShareMealApp(),
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
      theme:                      AppTheme.light,
      darkTheme:                  AppTheme.dark,
      themeMode: appState.isDarkMode ? ThemeMode.dark : ThemeMode.light,
      home:                       const LoginScreen(),
    );
  }
}