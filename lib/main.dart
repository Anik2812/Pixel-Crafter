import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:replica/screens/auth/login_page.dart';
import 'package:replica/screens/auth/registeration_page.dart';
import 'package:replica/screens/subscriptions/subscription_page.dart';
import 'package:replica/screens/home/home_page.dart';
import 'package:replica/screens/dashboard/dashboard_page.dart';
import 'package:replica/screens/settings/settings_page.dart';
import 'package:replica/constants/colors.dart';
import 'package:replica/services/project_service.dart'; // NEW
import 'package:replica/models/project.dart'; // NEW

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.light;

  ThemeMode get themeMode => _themeMode;

  void toggleTheme() {
    _themeMode =
        _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    notifyListeners();
  }
}

void main() {
  runApp(
    MultiProvider(
      // Using MultiProvider for multiple notifiers
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeNotifier()),
        ChangeNotifierProvider(create: (_) => ProjectService()), // NEW
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);

    return MaterialApp(
      title: 'Figma Replica App',
      debugShowCheckedModeBanner: false,
      themeMode: themeNotifier.themeMode,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surfaceLight,
          foregroundColor: AppColors.textPrimaryLight,
          elevation: 0,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryLight,
          ),
        ),
        scaffoldBackgroundColor: AppColors.backgroundLight,
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
        appBarTheme: AppBarTheme(
          backgroundColor: AppColors.surfaceDark,
          foregroundColor: AppColors.textPrimaryDark,
          elevation: 0,
          titleTextStyle: GoogleFonts.inter(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimaryDark,
          ),
        ),
        scaffoldBackgroundColor: AppColors.backgroundDark,
        textTheme:
            GoogleFonts.interTextTheme(Theme.of(context).textTheme).apply(
          bodyColor: AppColors.textPrimaryDark,
          displayColor: AppColors.textPrimaryDark,
        ),
        brightness: Brightness.dark,
      ),
      initialRoute: '/login',
      routes: {
        '/login': (context) => LoginPage(),
        '/register': (context) => RegistrationPage(),
        '/subscription': (context) => SubscriptionPage(),
        '/home': (context) => HomePage(),
        '/dashboard': (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          if (args is Project) {
            return DashboardPage(project: args);
          }
          // Fallback if no project is passed, create a new one
          final projectService =
              Provider.of<ProjectService>(context, listen: false);
          final newProject = projectService.createNewFile('Untitled Design');
          return DashboardPage(project: newProject);
        },
        '/settings': (context) => const SettingsPage(),
      },
    );
  }
}
