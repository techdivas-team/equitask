import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'api_services.dart'; // Make sure this import is correct (singular)
// import 'http_api_service.dart';       // Comment out for mock preview
import 'mock_api_service.dart'; // Add mock service import
import 'task_service.dart';
import 'auth_service.dart';
import 'notification_service.dart';
import 'user_service.dart';
// import '../constants.dart';            // Not needed for mock

class ServiceProvider extends StatelessWidget {
  final Widget child;

  const ServiceProvider({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Use MockApiService for preview – comment out HttpApiService
        Provider<ApiService>(
          create: (_) => MockApiService(), // Temporarily using mock
        ),
        // The original HttpApiService is commented out below
        // Provider<ApiService>(
        //   create: (_) => HttpApiService(baseUrl: apiBaseUrl),
        // ),

        // Other providers remain unchanged
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
