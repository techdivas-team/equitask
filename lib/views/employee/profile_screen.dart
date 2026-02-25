import 'package:flutter/material.dart';
import 'employee_drawer.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Profile')),
      drawer: const EmployeeDrawer(),
      body: const Center(child: Text('Profile Screen - Placeholder')),
    );
  }
}
