import 'package:flutter/material.dart';
import '../employee/widgets/support_fab_stack.dart';
import '../shared/notifications_content.dart';
import 'manager_drawer.dart';
import 'widgets/manager_top_bar.dart';

class ManagerNotificationsScreen extends StatelessWidget {
  const ManagerNotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: const ManagerTopBar(currentRoute: '/manager/notifications'),
      drawer: const ManagerDrawer(currentRoute: '/manager/notifications'),
      floatingActionButton: const SupportFabStack(showClipboard: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: const NotificationsContent(),
    );
  }
}
