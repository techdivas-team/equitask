import 'package:flutter/material.dart';
import 'employee_drawer.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      drawer: const EmployeeDrawer(),
      body: const Center(child: Text('Notifications Screen - Placeholder')),
    );
  }
}
