import 'package:flutter/material.dart';
import 'services/service_provider.dart';
import 'views/auth/login_screen.dart';
import 'views/auth/signup_screen.dart';
import 'views/auth/forgot_password_screen.dart';
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

  @override
  Widget build(BuildContext context) {
    return ServiceProvider(
      child: MaterialApp(
        title: 'EquiTask AI',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(primarySwatch: Colors.blue),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => const SignupScreen(),
          '/forgot-password': (context) => const ForgotPasswordScreen(),
          '/onboarding/role': (context) => const RoleSelectionScreen(),
          '/onboarding/accessibility': (context) => const AccessibilityScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/tasks': (context) => const TasksScreen(),
          '/notifications': (context) => const NotificationsScreen(),
          '/profile': (context) => const ProfileScreen(),
          '/settings': (context) => const SettingsScreen(),
          '/manager/dashboard': (context) => const ManagerDashboardScreen(),
          '/manager/verification': (context) => const ManagerVerificationScreen(),
          '/manager/create-task': (context) => const ManagerCreateTaskScreen(),
          '/manager/team': (context) => const ManagerTeamScreen(),
          '/manager/analytics': (context) => const ManagerAnalyticsScreen(),
          '/manager/notifications': (context) => const ManagerNotificationsScreen(),
          '/manager/profile': (context) => const ManagerProfileScreen(),
          '/manager/settings': (context) => const ManagerSettingsScreen(),
        },
      ),
    );
  }
}
