import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import 'widgets/auth_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;
  bool _emailSent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.forgotPassword(
        _emailController.text.trim(),
      );
      if (!mounted) return;
      if (success) {
        setState(() => _emailSent = true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to send reset email')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F6),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(22, 20, 22, 20),
          children: [
            const Text(
              'EquiTask AI',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Color(0xFF204A8A),
              ),
            ),
            const SizedBox(height: 4),
            const Text(
              'Inclusive Task Management',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.fromLTRB(22, 16, 22, 20),
              decoration: BoxDecoration(
                color: const Color(0xFFF8F8F8),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: const Color(0xFFD9DDE3)),
              ),
              child: _emailSent ? _buildSuccess(context) : _buildForm(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back, color: Color(0xFF364152)),
            label: const Text(
              'Back',
              style: TextStyle(
                color: Color(0xFF1F2937),
                fontWeight: FontWeight.w500,
              ),
            ),
            style: TextButton.styleFrom(padding: EdgeInsets.zero),
          ),
          const SizedBox(height: 16),
          const Center(
            child: Text(
              'Reset Password',
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.w600,
                color: Color(0xFF15283B),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Center(
            child: Text(
              'Enter your email and we will send reset instructions',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Email Address',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF253444),
            ),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _emailController,
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.trim().isEmpty) {
                return 'Please enter your email';
              }
              if (!value.contains('@')) {
                return 'Enter a valid email';
              }
              return null;
            },
            decoration: InputDecoration(
              hintText: 'Enter your email',
              hintStyle: const TextStyle(color: Color(0xFF7A828F), fontSize: 14),
              prefixIcon: const Icon(
                Icons.mail_outline,
                color: Color(0xFF7A828F),
                size: 22,
              ),
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
          const SizedBox(height: 24),
          AuthButton(
            text: 'Send Reset Instructions',
            onPressed: _handleReset,
            isLoading: _isLoading,
            backgroundColor: const Color(0xFF2F80ED),
          ),
        ],
      ),
    );
  }

  Widget _buildSuccess(BuildContext context) {
    return Column(
      children: [
        const Icon(Icons.mark_email_read_outlined, size: 72, color: Color(0xFF2F80ED)),
        const SizedBox(height: 20),
        const Text(
          'Check your email',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: Color(0xFF15283B),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'We sent reset instructions to ${_emailController.text}.',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
        ),
        const SizedBox(height: 24),
        OutlinedButton(
          onPressed: () => Navigator.pop(context),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: Color(0xFFD1D5DB)),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            minimumSize: const Size(double.infinity, 48),
          ),
          child: const Text(
            'Back to Sign In',
            style: TextStyle(color: Color(0xFF1F2937), fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }
}
