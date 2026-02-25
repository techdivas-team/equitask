import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/session_service.dart';
import 'widgets/selectable_card.dart';

class AccountTypeScreen extends StatefulWidget {
  const AccountTypeScreen({super.key});

  @override
  State<AccountTypeScreen> createState() => _AccountTypeScreenState();
}

class _AccountTypeScreenState extends State<AccountTypeScreen> {
  AccountMode? _selectedMode = AccountMode.organization;

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
                "Let's Set Up Your Workspace",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Organization mode is enabled now. Individual mode can be added next.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 15),
              ),
              const SizedBox(height: 30),
              SelectableCard(
                title: "Organization",
                description:
                    "Managers create and control organization workspaces. Employees join by invitation only.",
                icon: Icons.apartment_outlined,
                isSelected: _selectedMode == AccountMode.organization,
                onTap: () {
                  setState(() => _selectedMode = AccountMode.organization);
                },
              ),
              SelectableCard(
                title: "Individual (Coming Soon)",
                description:
                    "Personal task workspace without an organization structure.",
                icon: Icons.person_outline,
                isSelected: _selectedMode == AccountMode.individual,
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Individual mode is not enabled yet. Use Organization mode.',
                      ),
                    ),
                  );
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final session = Provider.of<SessionService>(
                      context,
                      listen: false,
                    );
                    session.selectAccountMode(AccountMode.organization);
                    Navigator.pushNamed(context, '/onboarding/role');
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
