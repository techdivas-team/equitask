import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
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
  User? _user;
  bool _isLoading = true;

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
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: const EmployeeTopBar(currentRoute: '/profile'),
      drawer: const EmployeeDrawer(currentRoute: '/profile'),
      floatingActionButton: const SupportFabStack(showClipboard: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadProfile,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
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
                            _initials(_user?.name ?? ''),
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
                                _user?.name ?? 'Unknown User',
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                _user?.email ?? '-',
                                style: const TextStyle(fontSize: 14, color: Color(0xFFE5E7EB)),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  _profileTile(Icons.badge_outlined, 'Employee ID', _user?.id ?? '-'),
                  _profileTile(Icons.work_outline, 'Role', 'Employee'),
                  _profileTile(Icons.schedule, 'Work Mode', 'Hybrid'),
                ],
              ),
            ),
    );
  }

  Widget _profileTile(IconData icon, String label, String value) {
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
