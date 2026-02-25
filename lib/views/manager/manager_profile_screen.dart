import 'package:flutter/material.dart';
import '../employee/widgets/support_fab_stack.dart';
import 'manager_drawer.dart';
import 'widgets/manager_top_bar.dart';

class ManagerProfileScreen extends StatelessWidget {
  const ManagerProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: const ManagerTopBar(currentRoute: '/manager/profile'),
      drawer: const ManagerDrawer(currentRoute: '/manager/profile'),
      floatingActionButton: const SupportFabStack(showClipboard: true),
      body: const Center(child: Text('Manager profile')),
    );
  }
}
