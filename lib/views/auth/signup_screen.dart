import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';
import 'widgets/auth_button.dart';
import 'widgets/google_icon.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSignup() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.signupManager(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (success) {
        if (!mounted) return;
        final session = Provider.of<SessionService>(context, listen: false);
        final token = authService.lastToken;
        if (token == null || token.isEmpty) {
          throw Exception('Missing auth token from backend');
        }
        session.startSession(
          token: token,
          email: authService.lastEmail ?? _emailController.text.trim(),
          role: authService.lastRole,
          organizationId: authService.lastOrganizationId,
        );
        Navigator.pushReplacementNamed(context, '/onboarding/account-type');
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Signup failed')));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Signup error: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleSignup() async {
    setState(() => _isLoading = true);
    try {
      final authService = Provider.of<AuthService>(context, listen: false);
      final success = await authService.signUpWithGoogle();
      if (!mounted) return;
      if (success) {
        final session = Provider.of<SessionService>(context, listen: false);
        final token = authService.lastToken;
        if (token == null || token.isEmpty) {
          throw Exception('Missing auth token from backend');
        }
        session.startSession(
          token: token,
          email: authService.lastEmail ?? _emailController.text.trim(),
          role: authService.lastRole,
          organizationId: authService.lastOrganizationId,
        );
        Navigator.pushReplacementNamed(context, '/onboarding/account-type');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign up cancelled')),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Google sign up failed: $e')));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F6F6),
      body: SafeArea(
        child: Form(
          key: _formKey,
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
                        'Create Manager\nAccount',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 28,
                          height: 1.08,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF15283B),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Center(
                      child: Text(
                        'Set up your organization and invite employees',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          height: 1.35,
                          color: Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFECF3FF),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFBCD5FF)),
                      ),
                      child: const Text(
                        'Employee self-signup is disabled. Employees join only through manager invitations.',
                        style: TextStyle(
                          fontSize: 12,
                          color: Color(0xFF234A99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildInput(
                      label: 'Full Name',
                      hint: 'Enter your full name',
                      icon: Icons.person_outline,
                      controller: _nameController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInput(
                      label: 'Email Address',
                      hint: 'Enter your email',
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      controller: _emailController,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your email';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildInput(
                      label: 'Password',
                      hint: 'Create a strong password',
                      icon: Icons.lock_outline,
                      obscureText: _obscurePassword,
                      controller: _passwordController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a password';
                        }
                        if (value.length < 6) {
                          return 'Password must be at least 6 characters';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _obscurePassword = !_obscurePassword);
                        },
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Password must be at least 6 characters',
                      style: TextStyle(fontSize: 12, color: Color(0xFF6B7280)),
                    ),
                    const SizedBox(height: 16),
                    _buildInput(
                      label: 'Confirm Password',
                      hint: 'Re-enter your password',
                      icon: Icons.lock_outline,
                      obscureText: _obscureConfirm,
                      controller: _confirmPasswordController,
                      validator: (value) {
                        if (value != _passwordController.text) {
                          return 'Passwords do not match';
                        }
                        return null;
                      },
                      suffixIcon: IconButton(
                        onPressed: () {
                          setState(() => _obscureConfirm = !_obscureConfirm);
                        },
                        icon: Icon(
                          _obscureConfirm
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                          color: const Color(0xFF6B7280),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    AuthButton(
                      text: 'Create Manager Account',
                      onPressed: _handleSignup,
                      isLoading: _isLoading,
                      backgroundColor: const Color(0xFF2F80ED),
                    ),
                    const SizedBox(height: 22),
                    const Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFFD4D9DF))),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 14),
                          child: Text(
                            'Or continue with',
                            style: TextStyle(
                              color: Color(0xFF6B7280),
                              fontSize: 14,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFD4D9DF))),
                      ],
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: OutlinedButton.icon(
                        onPressed: _isLoading ? null : _handleGoogleSignup,
                        icon: const GoogleIcon(),
                        label: const Text(
                          'Sign up with Google',
                          style: TextStyle(
                            color: Color(0xFF1F2937),
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: Color(0xFFD1D5DB)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          'Already have an account? ',
                          style: TextStyle(color: Color(0xFF6B7280), fontSize: 16),
                        ),
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          style: TextButton.styleFrom(
                            minimumSize: Size.zero,
                            padding: const EdgeInsets.symmetric(horizontal: 4),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(
                            'Sign In',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF2F80ED),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInput({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    required String? Function(String?) validator,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    Widget? suffixIcon,
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
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF7A828F), fontSize: 14),
            prefixIcon: Icon(icon, color: const Color(0xFF7A828F), size: 22),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 14,
            ),
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
