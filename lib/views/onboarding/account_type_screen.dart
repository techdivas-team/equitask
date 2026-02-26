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
  bool _initializedSelection = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_initializedSelection) return;
    _selectedMode = Provider.of<SessionService>(context, listen: false).accountMode;
    _initializedSelection = true;
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
                "Let's Set Up Your Workspace",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                "Choose how you want to use EquiTask AI.",
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
                title: "Individual",
                description:
                    "Personal task workspace without an organization structure.",
                icon: Icons.person_outline,
                isSelected: _selectedMode == AccountMode.individual,
                onTap: () {
                  setState(() => _selectedMode = AccountMode.individual);
                },
              ),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_selectedMode == null) return;
                    final session = Provider.of<SessionService>(
                      context,
                      listen: false,
                    );
                    session.selectAccountMode(_selectedMode!);
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
