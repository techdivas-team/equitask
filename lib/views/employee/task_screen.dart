import 'package:flutter/material.dart';
import 'employee_drawer.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Tasks')),
      drawer: const EmployeeDrawer(),
      body: const Center(child: Text('Tasks Screen - Placeholder')),
    );
  }
}
