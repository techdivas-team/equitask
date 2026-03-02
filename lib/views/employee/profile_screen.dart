import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../services/session_service.dart';
import '../../services/user_service.dart';
import 'employee_drawer.dart';
import 'widgets/employee_top_bar.dart';
import 'widgets/support_fab_stack.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final UserService _userService;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  User? _user;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userService = Provider.of<UserService>(context);
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      final user = await _userService.getCurrentUser();
      if (!mounted) return;
      setState(() {
        _user = user;
        _nameController.text = user.name;
        _emailController.text = user.email;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to load profile: $e')));
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      final updated = await _userService.updateCurrentUser(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _user = updated);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to save profile: $e')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionService>(context);
    final isHighContrast = session.highContrastEnabled;
    return Scaffold(
      backgroundColor: isHighContrast ? Colors.black : const Color(0xFFF3F5F7),
      appBar: const EmployeeTopBar(currentRoute: '/profile'),
      drawer: const EmployeeDrawer(currentRoute: '/profile'),
      floatingActionButton: const SupportFabStack(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: Form(
                key: _formKey,
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                  children: [
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2F80ED), Color(0xFF132B44)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFFDCEBFF),
                            child: Text(
                              _initials(_nameController.text),
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF132B44),
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _nameController.text.isEmpty
                                      ? 'Unknown User'
                                      : _nameController.text,
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _emailController.text.isEmpty
                                      ? '-'
                                      : _emailController.text,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    color: Color(0xFFE5E7EB),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    _profileTile(
                      label: 'Full Name',
                      controller: _nameController,
                      icon: Icons.person_outline,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Name is required';
                        }
                        return null;
                      },
                    ),
                    _profileTile(
                      label: 'Email Address',
                      controller: _emailController,
                      icon: Icons.mail_outline,
                      keyboardType: TextInputType.emailAddress,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Email is required';
                        }
                        if (!value.contains('@')) {
                          return 'Enter a valid email';
                        }
                        return null;
                      },
                    ),
                    _infoTile(
                      Icons.badge_outlined,
                      'Employee ID',
                      _user?.id.isNotEmpty == true ? _user!.id : '-',
                    ),
                    _infoTile(Icons.work_outline, 'Role', 'Employee'),
                    const SizedBox(height: 14),
                    SizedBox(
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: _isSaving ? null : _saveProfile,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF2F80ED),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        icon: _isSaving
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.save_outlined),
                        label: Text(_isSaving ? 'Saving...' : 'Save Profile'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _profileTile({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String? Function(String?) validator,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8DDE6)),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          isDense: true,
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF4B5563)),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8DDE6)),
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF4B5563)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF15283B),
            ),
          ),
        ],
      ),
    );
  }

  String _initials(String name) {
    final chunks = name.trim().split(RegExp(r'\s+'));
    if (chunks.isEmpty || chunks.first.isEmpty) return 'U';
    if (chunks.length == 1) return chunks.first[0].toUpperCase();
    return '${chunks.first[0]}${chunks.last[0]}'.toUpperCase();
  }
}
