import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/auth_service.dart';

class EmployeeDrawer extends StatelessWidget {
  final String currentRoute;

  const EmployeeDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final authService = Provider.of<AuthService>(context, listen: false);
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
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 2),
              const Text(
                'Employee Portal',
                style: TextStyle(
                  fontSize: 16,
                  color: Color(0xFFB8C5D1),
                ),
              ),
              const SizedBox(height: 20),
              _drawerItem(
                context: context,
                icon: Icons.home_outlined,
                label: 'Dashboard',
                route: '/dashboard',
              ),
              _drawerItem(
                context: context,
                icon: Icons.playlist_add_check_circle_outlined,
                label: 'My Tasks',
                route: '/tasks',
              ),
              _drawerItem(
                context: context,
                icon: Icons.notifications_none_outlined,
                label: 'Notifications',
                route: '/notifications',
              ),
              _drawerItem(
                context: context,
                icon: Icons.account_circle_outlined,
                label: 'Profile',
                route: '/profile',
              ),
              _drawerItem(
                context: context,
                icon: Icons.settings_outlined,
                label: 'Settings',
                route: '/settings',
              ),
              const Spacer(),
              const Divider(color: Color(0xFF29435C)),
              const SizedBox(height: 6),
              ListTile(
                leading: const Icon(Icons.logout, color: Color(0xFFE2E8F0)),
                title: const Text(
                  'Logout',
                  style: TextStyle(color: Color(0xFFE2E8F0), fontSize: 16),
                ),
                onTap: () async {
                  await authService.logout();
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

  Widget _drawerItem({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
  }) {
    final active = route == currentRoute;
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
          style: const TextStyle(
            color: Color(0xFFE2E8F0),
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        onTap: () {
          Navigator.pop(context);
          if (active) return;
          Navigator.pushReplacementNamed(context, route);
        },
      ),
    );
  }
}
