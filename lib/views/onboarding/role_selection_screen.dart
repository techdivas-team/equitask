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
  void didChangeDependencies() {
    super.didChangeDependencies();
    final session = Provider.of<SessionService>(context, listen: false);
    if (selectedRole != null) return;
    if (session.accountMode == AccountMode.individual) {
      selectedRole = 'individual';
      return;
    }
    final currentRole = session.role;
    if (currentRole == AppRole.manager) {
      selectedRole = 'manager';
    } else if (currentRole == AppRole.employee) {
      selectedRole = 'employee';
    }
  }

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
                  final isOrganization =
                      session.accountMode == AccountMode.organization;
                  return Text(
                    isOrganization
                        ? "Select Your Role in Organization"
                        : "You are using Individual Mode",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  );
                },
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Consumer<SessionService>(
                  builder: (_, session, __) {
                    final isOrganization =
                        session.accountMode == AccountMode.organization;
                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          if (isOrganization)
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
                            title: isOrganization ? "Manager" : "Individual",
                            description: isOrganization
                                ? "Create and manage organization workspace, teams, and invitations"
                                : "Use your own workspace with manager-style navigation and tools",
                            icon: isOrganization
                                ? Icons.supervisor_account_outlined
                                : Icons.person_outline,
                            isSelected: selectedRole ==
                                (isOrganization ? "manager" : "individual"),
                            onTap: () {
                              setState(() {
                                selectedRole =
                                    isOrganization ? "manager" : "individual";
                              });
                            },
                          ),
                        ],
                      ),
                    );
                  },
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
                                AccessibilityScreen(
                                  selectedRole: selectedRole!,
                                ),
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
