import 'package:flutter/material.dart';
import 'employee_drawer.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      drawer: const EmployeeDrawer(),
      body: const Center(child: Text('Settings Screen - Placeholder')),
    );
  }
}
