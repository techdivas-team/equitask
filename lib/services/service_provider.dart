import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_services.dart';
import 'auth_service.dart';
import 'mock_api_service.dart';
import 'notification_service.dart';
import 'session_service.dart';
import 'task_service.dart';
import 'team_service.dart';
import 'user_service.dart';

class ServiceProvider extends StatelessWidget {
  final Widget child;

  const ServiceProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SessionService>(
          create: (_) => SessionService(),
        ),
        ChangeNotifierProvider<TeamService>(
          create: (_) => TeamService(),
        ),
        Provider<ApiService>(
          create: (_) => MockApiService(),
        ),
        ProxyProvider<ApiService, TaskService>(
          update: (_, api, __) => TaskService(api),
        ),
        ProxyProvider<ApiService, AuthService>(
          update: (_, api, __) => AuthService(api),
        ),
        ProxyProvider<ApiService, NotificationService>(
          update: (_, api, __) => NotificationService(api),
        ),
        ProxyProvider<ApiService, UserService>(
          update: (_, api, __) => UserService(api),
        ),
      ],
      child: child,
    );
  }
}
