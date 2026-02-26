import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/session_service.dart';
import 'widgets/selectable_card.dart';
import '../employee/dashboard_screen.dart';
import '../employee/task_screen.dart';
import '../manager/manager_dashboard_screen.dart';

class AccessibilityScreen extends StatefulWidget {
  final String selectedRole;

  const AccessibilityScreen({super.key, this.selectedRole = 'employee'});

  @override
  State<AccessibilityScreen> createState() => _AccessibilityScreenState();
}

class _AccessibilityScreenState extends State<AccessibilityScreen> {
  int selectedIndex =
      0; // 0: Standard, 1: High Contrast, 2: Large Text, 3: Simplified UI

  final List<Map<String, dynamic>> preferences = [
    {
      'title': 'Standard',
      'description':
          'Default interface with balanced colors and standard text sizes',
      'icon': Icons.palette_outlined,
    },
    {
      'title': 'High Contrast',
      'description':
          'Maximum contrast for better visibility and reduced eye strain',
      'icon': Icons.contrast_outlined,
    },
    {
      'title': 'Large Text',
      'description': 'Increased text size for improved readability',
      'icon': Icons.text_fields,
    },
    {
      'title': 'Simplified UI',
      'description': 'Reduced visual complexity with essential elements only',
      'icon': Icons.dashboard_customize_outlined,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text(
                "Welcome to EquiTask AI",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Inclusive task management for everyone",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
              const SizedBox(height: 30),
              const Text(
                "Choose Your Accessibility Preference",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: ListView.builder(
                  itemCount: preferences.length,
                  itemBuilder: (context, index) {
                    final pref = preferences[index];
                    return SelectableCard(
                      title: pref['title']!,
                      description: pref['description']!,
                      icon: pref['icon'],
                      isSelected: selectedIndex == index,
                      onTap: () {
                        setState(() {
                          selectedIndex = index;
                        });
                      },
                    );
                  },
                ),
              ),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("Back", style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        final session = Provider.of<SessionService>(
                          context,
                          listen: false,
                        );
                        final isIndividual =
                            session.accountMode == AccountMode.individual;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (context) {
                              if (isIndividual) {
                                return const TasksScreen();
                              }
                              return widget.selectedRole == 'manager'
                                  ? const ManagerDashboardScreen()
                                  : const DashboardScreen();
                            },
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        "Get Started",
                        style: TextStyle(fontSize: 16),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
