import 'package:flutter/material.dart';
import '../employee/widgets/support_fab_stack.dart';
import 'manager_drawer.dart';
import 'widgets/manager_top_bar.dart';

class ManagerDashboardScreen extends StatelessWidget {
  const ManagerDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: const ManagerTopBar(currentRoute: '/manager/dashboard'),
      drawer: const ManagerDrawer(currentRoute: '/manager/dashboard'),
      floatingActionButton: const SupportFabStack(showClipboard: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Manager Dashboard',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF15283B),
                  ),
                ),
              ),
              Tooltip(
                message: 'Create new task',
                child: InkWell(
                  onTap: () => Navigator.pushNamed(context, '/manager/create-task'),
                  borderRadius: BorderRadius.circular(20),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: const Color(0xFF2F80ED),
                      borderRadius: BorderRadius.circular(17),
                    ),
                    child: const Icon(Icons.add, color: Colors.white, size: 20),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Monitor team progress and verify task completions',
            style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 16),
          _metricCard(
            icon: Icons.groups_2_outlined,
            iconColor: const Color(0xFF2F80ED),
            bg: Colors.white,
            border: const Color(0xFFD8DDE6),
            label: 'Total Tasks',
            value: '6',
          ),
          const SizedBox(height: 12),
          _metricCard(
            icon: Icons.assignment_turned_in_outlined,
            iconColor: const Color(0xFFB76E00),
            bg: const Color(0xFFFAF8EA),
            border: const Color(0xFFE9D452),
            label: 'Pending Review',
            value: '1',
          ),
          const SizedBox(height: 12),
          _metricCard(
            icon: Icons.check_circle_outline,
            iconColor: const Color(0xFF0A8A66),
            bg: const Color(0xFFEAF8F2),
            border: const Color(0xFF76DABD),
            label: 'Verified',
            value: '1',
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F4FF),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFCAD8FF)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Team Progress', style: TextStyle(fontSize: 16, color: Color(0xFF2B4D9A))),
                    SizedBox(height: 8),
                    Text('17%', style: TextStyle(fontSize: 40, fontWeight: FontWeight.w500, color: Color(0xFF234A99))),
                  ],
                ),
                _progressCircle(0.17),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF2F80ED), Color(0xFF132B44)]),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Verification Center', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w700)),
                const SizedBox(height: 4),
                const Text('1 task waiting for your review', style: TextStyle(color: Color(0xFFDDE8F7), fontSize: 14)),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () => Navigator.pushNamed(context, '/manager/verification'),
                    icon: const Icon(Icons.visibility_outlined, color: Color(0xFF1F2937)),
                    label: const Text('Review Submissions', style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w600)),
                    style: OutlinedButton.styleFrom(backgroundColor: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'All Tasks Overview',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF15283B)),
          ),
          const SizedBox(height: 10),
          ..._overviewTasks(),
        ],
      ),
    );
  }

  Widget _metricCard({
    required IconData icon,
    required Color iconColor,
    required Color bg,
    required Color border,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 34),
          const SizedBox(height: 16),
          Text(label, style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
          const SizedBox(height: 10),
          Text(value, style: const TextStyle(fontSize: 24, color: Color(0xFF15283B))),
        ],
      ),
    );
  }

  Widget _progressCircle(double value) {
    return SizedBox(
      width: 84,
      height: 84,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(value: value, strokeWidth: 8, color: const Color(0xFF2F80ED), backgroundColor: const Color(0xFFE5E7EB)),
          Center(child: Text('${(value * 100).round()}%', style: const TextStyle(fontWeight: FontWeight.w700, color: Color(0xFF1F2937)))),
        ],
      ),
    );
  }

  List<Widget> _overviewTasks() {
    final data = [
      ('Complete Q1 Budget Report', 'Sarah Johnson', 'Draft', 'high', '27/02/2026', const Color(0xFFE73333)),
      ('Update Employee Training Materials', 'Michael Chen', 'Validated', 'medium', '28/02/2026', const Color(0xFFE8BE21)),
      ('Schedule Team Meeting', 'Emily Rodriguez', 'Under review', 'low', '26/02/2026', const Color(0xFF19B889)),
    ];
    return data.map((e) {
      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: const Color(0xFFD8DDE6)),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(width: 4, height: 92, decoration: BoxDecoration(color: e.$6, borderRadius: BorderRadius.circular(8))),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(e.$1, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600, color: Color(0xFF15283B))),
                  const SizedBox(height: 4),
                  Text('Assigned to: ${e.$2}', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      _tag(e.$3, const Color(0xFFE5E7EB), const Color(0xFF374151)),
                      _tag(e.$4, e.$6.withValues(alpha: 0.14), e.$6),
                      Text('Due ${e.$5}', style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  Widget _tag(String text, Color bg, Color fg) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(8), border: Border.all(color: fg.withValues(alpha: 0.35))),
      child: Text(text, style: TextStyle(fontSize: 12, color: fg, fontWeight: FontWeight.w600)),
    );
  }
}
