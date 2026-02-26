import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/service_provider.dart';
import 'services/session_service.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/auth/invite_employee_signup_screen.dart';
import 'views/auth/forgot_password_screen.dart';
import 'views/onboarding/account_type_screen.dart';
import 'views/onboarding/role_selection_screen.dart';
import 'views/onboarding/accessibility_screen.dart';
import 'views/employee/dashboard_screen.dart';
import 'views/employee/task_screen.dart'; // note the plural
import 'views/employee/notifications_screen.dart';
import 'views/employee/profile_screen.dart';
import 'views/employee/settings_screen.dart';
import 'views/manager/manager_dashboard_screen.dart';
import 'views/manager/manager_verification_screen.dart';
import 'views/manager/manager_create_task_screen.dart';
import 'views/manager/manager_team_screen.dart';
import 'views/manager/manager_analytics_screen.dart';
import 'views/manager/manager_notifications_screen.dart';
import 'views/manager/manager_profile_screen.dart';
import 'views/manager/manager_settings_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const Color _hcPrimary = Color(0xFF00D9FF);
  static const Color _hcSecondary = Color(0xFFFFD700);
  static const Color _hcSuccess = Color(0xFF00FF7F);
  static const Color _hcDestructive = Color(0xFFFF3366);

  @override
  Widget build(BuildContext context) {
    return ServiceProvider(
      child: Consumer<SessionService>(
        builder: (_, session, __) => MaterialApp(
          title: 'EquiTask AI',
          debugShowCheckedModeBanner: false,
          theme: _buildTheme(session),
          builder: (context, child) {
            final media = MediaQuery.of(context);
            final scale = session.largeTextEnabled ? 1.2 : 1.0;
            final adapted = media.copyWith(
              textScaler: TextScaler.linear(scale),
              boldText: session.screenReaderAssistEnabled
                  ? true
                  : media.boldText,
            );
            return MediaQuery(data: adapted, child: child ?? const SizedBox());
          },
          initialRoute: '/login',
          routes: {
            '/login': (context) => const LoginScreen(),
            '/signup': (context) => const SignupScreen(),
            '/forgot-password': (context) => const ForgotPasswordScreen(),
            '/signup/invite-employee': (context) =>
                const InviteEmployeeSignupScreen(),
            '/onboarding/account-type': (context) => const AccountTypeScreen(),
            '/onboarding/role': (context) => const RoleSelectionScreen(),
            '/onboarding/accessibility': (context) =>
                const AccessibilityScreen(),
            '/dashboard': (context) => const DashboardScreen(),
            '/tasks': (context) => const TasksScreen(),
            '/notifications': (context) => const NotificationsScreen(),
            '/profile': (context) => const ProfileScreen(),
            '/settings': (context) => const SettingsScreen(),
            '/manager/dashboard': (context) => const ManagerDashboardScreen(),
            '/manager/verification': (context) =>
                const ManagerVerificationScreen(),
            '/manager/create-task': (context) =>
                const ManagerCreateTaskScreen(),
            '/manager/team': (context) => const ManagerTeamScreen(),
            '/manager/analytics': (context) => const ManagerAnalyticsScreen(),
            '/manager/notifications': (context) =>
                const ManagerNotificationsScreen(),
            '/manager/profile': (context) => const ManagerProfileScreen(),
            '/manager/settings': (context) => const ManagerSettingsScreen(),
          },
        ),
      ),
    );
  }

  ThemeData _buildTheme(SessionService session) {
    if (!session.highContrastEnabled) {
      return ThemeData(primarySwatch: Colors.blue);
    }
    return ThemeData(
      colorScheme: const ColorScheme(
        brightness: Brightness.dark,
        primary: _hcPrimary,
        onPrimary: Colors.black,
        secondary: _hcSecondary,
        onSecondary: Colors.black,
        error: _hcDestructive,
        onError: Colors.black,
        surface: Colors.black,
        onSurface: Colors.white,
      ),
      scaffoldBackgroundColor: Colors.black,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      textTheme: ThemeData.dark().textTheme.apply(
        bodyColor: Colors.white,
        displayColor: Colors.white,
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: Colors.black,
        contentTextStyle: TextStyle(color: Colors.white),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _hcSuccess,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _hcPrimary,
          foregroundColor: Colors.black,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _hcSecondary,
          side: const BorderSide(color: _hcSecondary),
        ),
      ),
      extensions: const <ThemeExtension<dynamic>>[],
    );
  }
}
