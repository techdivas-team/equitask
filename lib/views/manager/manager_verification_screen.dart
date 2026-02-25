import 'package:flutter/material.dart';
import '../employee/widgets/support_fab_stack.dart';
import 'manager_drawer.dart';
import 'widgets/manager_top_bar.dart';

class ManagerVerificationScreen extends StatelessWidget {
  const ManagerVerificationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: const ManagerTopBar(currentRoute: '/manager/verification'),
      drawer: const ManagerDrawer(currentRoute: '/manager/verification'),
      floatingActionButton: const SupportFabStack(showClipboard: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          const Text(
            'Verification Center',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF15283B)),
          ),
          const SizedBox(height: 4),
          const Text(
            'Review and approve employee task submissions',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFAF8EA),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFE9D452)),
            ),
            child: const Row(
              children: [
                CircleAvatar(
                  backgroundColor: Color(0xFFF4EEBF),
                  child: Icon(Icons.check_circle_outline, color: Color(0xFFC58B00)),
                ),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Pending Reviews', style: TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
                    SizedBox(height: 3),
                    Text('0', style: TextStyle(fontSize: 26, color: Color(0xFF15283B))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD8DDE6)),
            ),
            child: const Column(
              children: [
                Icon(Icons.check_circle_outline, size: 88, color: Color(0xFF6B7280)),
                SizedBox(height: 10),
                Text('All Caught Up!', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
                SizedBox(height: 12),
                Text(
                  'There are no submissions waiting for your review.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
