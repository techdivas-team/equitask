import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/session_service.dart';
import 'widgets/selectable_card.dart';
import 'accessibility_screen.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  String? selectedRole;

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
              Consumer<SessionService>(
                builder: (_, session, __) {
                  return Text(
                    session.accountMode == AccountMode.organization
                        ? "Select Your Role in Organization"
                        : "Select Your Role",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      SelectableCard(
                        title: "Employee",
                        description:
                            "Join your manager's organization using an invitation code",
                        icon: Icons.person_outline,
                        isSelected: selectedRole == "employee",
                        onTap: () {
                          setState(() {
                            selectedRole = "employee";
                          });
                        },
                      ),
                      SelectableCard(
                        title: "Manager",
                        description:
                            "Create and manage organization workspace, teams, and invitations",
                        icon: Icons.supervisor_account_outlined,
                        isSelected: selectedRole == "manager",
                        onTap: () {
                          setState(() {
                            selectedRole = "manager";
                          });
                        },
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: selectedRole == null
                      ? null
                      : () {
                        final session = Provider.of<SessionService>(
                          context,
                          listen: false,
                        );
                        final isOrg =
                            session.accountMode == AccountMode.organization;
                        if (isOrg &&
                            selectedRole == 'employee' &&
                            !session.hasValidInvite) {
                          Navigator.pushNamed(context, '/signup/invite-employee');
                          return;
                        }
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AccessibilityScreen(selectedRole: selectedRole!),
                          ),
                        );
                      },
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text("Continue", style: TextStyle(fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
