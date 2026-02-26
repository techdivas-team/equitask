import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';
import '../../services/session_service.dart';

class ManagerDrawer extends StatelessWidget {
  final String currentRoute;

  const ManagerDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
    final session = Provider.of<SessionService>(context);
    final isPersonal = session.accountMode == AccountMode.individual;
    return Drawer(
      backgroundColor: const Color(0xFF132B44),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              const Text(
                'EquiTask AI',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Colors.white),
              ),
              const SizedBox(height: 4),
              Text(
                isPersonal ? 'Personal Portal' : 'Manager Portal',
                style: TextStyle(fontSize: 14, color: Color(0xFFB8C5D1)),
              ),
              const SizedBox(height: 18),
              _item(context, Icons.home_outlined, 'Dashboard', '/manager/dashboard'),
              if (isPersonal) ...[
                _item(context, Icons.playlist_add_check_circle_outlined, 'My Tasks', '/tasks'),
                _item(context, Icons.person_add_alt_1_outlined, 'Invite Member', '/manager/team'),
              ] else ...[
                _item(context, Icons.fact_check_outlined, 'Verification Center', '/manager/verification'),
                _item(context, Icons.add, 'Create Task', '/manager/create-task'),
                _item(context, Icons.groups_2_outlined, 'Team', '/manager/team'),
                _item(context, Icons.bar_chart_outlined, 'Analytics', '/manager/analytics'),
                _item(context, Icons.notifications_none_outlined, 'Notifications', '/manager/notifications'),
              ],
              _item(context, Icons.account_circle_outlined, 'Profile', '/manager/profile'),
              _item(context, Icons.settings_outlined, 'Settings', '/manager/settings'),
              const Spacer(),
              const Divider(color: Color(0xFF29435C)),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFE2E8F0)),
                title: const Text('Logout', style: TextStyle(color: Color(0xFFE2E8F0))),
                onTap: () async {
                  try {
                    await authService.logout();
                  } catch (_) {}
                  if (!context.mounted) return;
                  session.clearSession();
                  if (!context.mounted) return;
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, String route) {
    final active = currentRoute == route;
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: active ? const Color(0xFF2F80ED) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: const Color(0xFFE2E8F0)),
        title: Text(
          label,
          style: const TextStyle(color: Color(0xFFE2E8F0), fontSize: 16, fontWeight: FontWeight.w500),
        ),
        onTap: () {
          Navigator.pop(context);
          if (!active) Navigator.pushReplacementNamed(context, route);
        },
      ),
    );
  }
}
