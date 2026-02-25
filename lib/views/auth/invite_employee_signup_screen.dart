import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';
import 'widgets/auth_button.dart';

class InviteEmployeeSignupScreen extends StatefulWidget {
  const InviteEmployeeSignupScreen({super.key});

  @override
  State<InviteEmployeeSignupScreen> createState() =>
      _InviteEmployeeSignupScreenState();
}

class _InviteEmployeeSignupScreenState extends State<InviteEmployeeSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _inviteCodeController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _inviteCodeController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final session = Provider.of<SessionService>(context, listen: false);

      final validInvite = await authService.validateInvitationCode(
        _inviteCodeController.text.trim(),
      );
      if (!validInvite) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid invitation code')),
        );
        return;
      }

      session.setInviteState(isValid: true);

      final success = await authService.signupInvitedEmployee(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        invitationCode: _inviteCodeController.text.trim(),
      );

      if (!mounted) return;
      if (success) {
        session.startSession(
          token: authService.lastToken ?? 'mock_employee_token',
          email: authService.lastEmail ?? _emailController.text.trim(),
          role: AppRole.employee,
          organizationId: authService.lastOrganizationId,
        );
        Navigator.pushReplacementNamed(context, '/onboarding/account-type');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create employee account')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Invite signup failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xFFF2F6F6),
        elevation: 0,
        foregroundColor: const Color(0xFF1F2937),
        title: const Text('Join Organization'),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(22, 12, 22, 20),
            children: [
              const Text(
                'Employee accounts require an invitation from your manager.',
                style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 18),
              _input(
                controller: _inviteCodeController,
                label: 'Invitation Code',
                hint: 'Enter invite code',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Invite code is required'
                    : null,
              ),
              const SizedBox(height: 12),
              _input(
                controller: _nameController,
                label: 'Full Name',
                hint: 'Enter your name',
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Name is required'
                    : null,
              ),
              const SizedBox(height: 12),
              _input(
                controller: _emailController,
                label: 'Work Email',
                hint: 'Enter your work email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) =>
                    value == null || !value.contains('@')
                        ? 'Enter a valid email'
                        : null,
              ),
              const SizedBox(height: 12),
              _input(
                controller: _passwordController,
                label: 'Password',
                hint: 'Create password',
                obscureText: true,
                validator: (value) =>
                    value == null || value.length < 6
                        ? 'Minimum 6 characters'
                        : null,
              ),
              const SizedBox(height: 20),
              AuthButton(
                text: 'Join Organization',
                onPressed: _submit,
                isLoading: _isLoading,
                backgroundColor: const Color(0xFF2F80ED),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _input({
    required TextEditingController controller,
    required String label,
    required String hint,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF253444),
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD8DCE2)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFD8DCE2)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFF2F80ED)),
            ),
          ),
        ),
      ],
    );
  }
}
