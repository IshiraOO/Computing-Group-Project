import 'package:first_aid_health_care/screens/emergency_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'services/local_storage_service.dart';
import 'services/theme_service.dart';
import 'common/app_theme.dart';

import 'screens/auth_wrapper.dart';
import 'screens/main_navigation_screen.dart';
import 'screens/user_profile_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/first_aid_screen.dart';
import 'screens/illness_database_screen.dart';
import 'screens/hospital_locator_screen.dart';
import 'screens/training_modules_screen.dart';
import 'screens/community_support_screen.dart';
import 'screens/health_journal_screen.dart';
import 'screens/symptom_analysis_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Initialize Hive for local storage
  await LocalStorageService.init();

  // Initialize theme service
  final themeService = ThemeService();
  await themeService.init();

  runApp(ChangeNotifierProvider.value(
    value: themeService,
    child: const MainApp(),
  ));
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeService = Provider.of<ThemeService>(context);

    // Update system UI overlay style based on theme
    final isDark = themeService.isDarkMode;
    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        systemNavigationBarColor:
            isDark ? const Color(0xFF1E1E1E) : Colors.white,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
    );

    return MaterialApp(
      title: 'First Aid Health Care',
      themeMode: themeService.themeMode,
      theme: AppTheme.getLightTheme(),
      darkTheme: AppTheme.getDarkTheme(),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
      // Define named routes for navigation
      routes: {
        '/emergency-contacts': (context) => const EmergencyScreen(),
        '/first-aid': (context) => const FirstAidScreen(),
        '/home': (context) => const MainNavigationScreen(),
        '/hospital-locator': (context) => const HospitalLocatorScreen(),
        '/illness-database': (context) => const IllnessDatabaseScreen(),
        '/login': (context) => const LoginScreen(),
        '/profile': (context) => const UserProfileScreen(),
        '/register': (context) => const RegisterScreen(),
        '/training-modules': (context) => const TrainingModulesScreen(),
        '/community-support': (context) => const CommunitySupportScreen(),
        '/health-journal': (context) => const HealthJournalScreen(),
        '/symptom-analysis': (context) => const SymptomAnalysisScreen(),
      },
    );
  }
}
