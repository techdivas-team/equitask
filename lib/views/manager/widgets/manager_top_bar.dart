import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/session_service.dart';

class ManagerTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;

  const ManagerTopBar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionService>(context);
    final isPersonal = session.accountMode == AccountMode.individual;
    final isHighContrast = session.highContrastEnabled;
    final dashboardRoute = isPersonal ? '/dashboard' : '/manager/dashboard';
    final notificationsRoute = isPersonal
        ? '/notifications'
        : '/manager/notifications';
    final settingsRoute = isPersonal ? '/settings' : '/manager/settings';
    final profileRoute = isPersonal ? '/profile' : '/manager/profile';
    final background = isHighContrast ? Colors.black : Colors.white;
    final inactiveIcon = isHighContrast
        ? Colors.white
        : const Color(0xFF344054);

    return AppBar(
      backgroundColor: background,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: Icon(Icons.menu, color: inactiveIcon),
        ),
      ),
      actions: [
        _icon(
          context,
          icon: Icons.home_outlined,
          route: dashboardRoute,
          active: currentRoute == dashboardRoute,
          inactiveIconColor: inactiveIcon,
          isHighContrast: isHighContrast,
        ),
        _icon(
          context,
          icon: Icons.notifications_none_outlined,
          route: notificationsRoute,
          active: currentRoute == notificationsRoute,
          dot: true,
          inactiveIconColor: inactiveIcon,
          isHighContrast: isHighContrast,
        ),
        _icon(
          context,
          icon: Icons.settings_outlined,
          route: settingsRoute,
          active: currentRoute == settingsRoute,
          boxed: true,
          inactiveIconColor: inactiveIcon,
          isHighContrast: isHighContrast,
        ),
        _icon(
          context,
          icon: Icons.account_circle_outlined,
          route: profileRoute,
          active: currentRoute == profileRoute,
          inactiveIconColor: inactiveIcon,
          isHighContrast: isHighContrast,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _icon(
    BuildContext context, {
    required IconData icon,
    required String route,
    required bool active,
    required Color inactiveIconColor,
    required bool isHighContrast,
    bool boxed = false,
    bool dot = false,
  }) {
    final button = IconButton(
      onPressed: () => Navigator.pushReplacementNamed(context, route),
      icon: Icon(
        icon,
        color: active ? const Color(0xFF2F80ED) : inactiveIconColor,
      ),
    );
    final widget = boxed
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isHighContrast ? Colors.white : const Color(0xFFD0D5DD),
              ),
            ),
            child: button,
          )
        : button;
    if (!dot) return widget;
    return Stack(
      children: [
        widget,
        const Positioned(
          top: 11,
          right: 11,
          child: DecoratedBox(
            decoration: BoxDecoration(shape: BoxShape.circle, color: Color(0xFFFF3347)),
            child: SizedBox(width: 9, height: 9),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
