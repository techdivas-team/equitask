import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/session_service.dart';
import '../shared/notifications_content.dart';
import 'employee_drawer.dart';
import 'widgets/employee_top_bar.dart';
import 'widgets/support_fab_stack.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isHighContrast = Provider.of<SessionService>(
      context,
    ).highContrastEnabled;
    return Scaffold(
      backgroundColor: isHighContrast ? Colors.black : const Color(0xFFF3F5F7),
      appBar: const EmployeeTopBar(currentRoute: '/notifications'),
      drawer: const EmployeeDrawer(currentRoute: '/notifications'),
      floatingActionButton: const SupportFabStack(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: const NotificationsContent(),
    );
  }
}
