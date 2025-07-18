import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/medication_schedule_screen.dart';
import 'screens/health_logs_screen.dart';
import 'screens/appointments_screen.dart';
import 'screens/profile_screen.dart';
import 'providers/user_provider.dart';
import 'providers/health_logs_provider.dart';
import 'providers/theme_provider.dart';

void main() {
  runApp(MyMedBuddyApp());
}

class MyMedBuddyApp extends StatelessWidget {
  const MyMedBuddyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Provider for user data management
        ChangeNotifierProvider(create: (context) => UserProvider()),
        // Provider for health logs management
        ChangeNotifierProvider(create: (context) => HealthLogsProvider()),
        // Provider for theme management
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'MyMedBuddy',
            debugShowCheckedModeBanner: false,
            // Brown theme configuration
            theme: ThemeData(
              primarySwatch: Colors.brown,
              primaryColor: Color(0xFF8D6E63),
              scaffoldBackgroundColor: Color(0xFFFFF8E1),
              cardColor: Color(0xFFEFEBE9),
              appBarTheme: AppBarTheme(
                backgroundColor: Color(0xFF8D6E63),
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF8D6E63),
                  foregroundColor: Colors.white,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFF8D6E63), width: 2),
                ),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: MaterialStateProperty.resolveWith<Color?>((
                  Set<MaterialState> states,
                ) {
                  if (states.contains(MaterialState.selected)) {
                    return Color(0xFF8D6E63);
                  }
                  return null;
                }),
                trackColor: MaterialStateProperty.resolveWith<Color?>((
                  Set<MaterialState> states,
                ) {
                  if (states.contains(MaterialState.selected)) {
                    return Color(0xFF8D6E63).withOpacity(0.5);
                  }
                  return null;
                }),
              ),
              // Light theme for brown colors
              brightness: Brightness.light,
            ),
            // Dark theme with brown accent
            darkTheme: ThemeData(
              primarySwatch: Colors.brown,
              primaryColor: Color(0xFFBCAAA4),
              scaffoldBackgroundColor: Color(0xFF121212),
              cardColor: Color(0xFF1E1E1E),
              appBarTheme: AppBarTheme(
                backgroundColor: Color(0xFF1E1E1E),
                foregroundColor: Colors.white,
                elevation: 2,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFBCAAA4),
                  foregroundColor: Colors.black,
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: BorderSide(color: Color(0xFFBCAAA4), width: 2),
                ),
                labelStyle: TextStyle(color: Color(0xFFBCAAA4)),
              ),
              switchTheme: SwitchThemeData(
                thumbColor: MaterialStateProperty.resolveWith<Color?>((
                  Set<MaterialState> states,
                ) {
                  if (states.contains(MaterialState.selected)) {
                    return Color(0xFFBCAAA4);
                  }
                  return null;
                }),
                trackColor: MaterialStateProperty.resolveWith<Color?>((
                  Set<MaterialState> states,
                ) {
                  if (states.contains(MaterialState.selected)) {
                    return Color(0xFFBCAAA4).withOpacity(0.5);
                  }
                  return null;
                }),
              ),
              textTheme: TextTheme(
                bodyLarge: TextStyle(color: Colors.white),
                bodyMedium: TextStyle(color: Colors.white70),
                titleLarge: TextStyle(color: Colors.white),
                titleMedium: TextStyle(color: Colors.white),
              ),
              iconTheme: IconThemeData(color: Colors.white70),
              brightness: Brightness.dark,
            ),
            // FIXED: Use themeProvider.isDarkMode instead of ThemeMode.system
            themeMode: themeProvider.isDarkMode
                ? ThemeMode.dark
                : ThemeMode.light,
            // Initial route determination
            home: FutureBuilder<bool>(
              future: _checkOnboardingStatus(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Scaffold(
                    body: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF8D6E63),
                        ),
                      ),
                    ),
                  );
                }
                // Navigate to home if onboarding completed, otherwise to onboarding
                return snapshot.data == true
                    ? HomeScreen()
                    : OnboardingScreen();
              },
            ),
            // Named routes for navigation
            routes: {
              '/onboarding': (context) => OnboardingScreen(),
              '/home': (context) => HomeScreen(),
              '/medication-schedule': (context) => MedicationScheduleScreen(),
              '/health-logs': (context) => HealthLogsScreen(),
              '/appointments': (context) => AppointmentsScreen(),
              '/profile': (context) => ProfileScreen(),
            },
          );
        },
      ),
    );
  }

  // Check if user has completed onboarding
  Future<bool> _checkOnboardingStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_completed') ?? false;
  }
}
