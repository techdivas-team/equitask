import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../services/session_service.dart';

class EmployeeTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;

  const EmployeeTopBar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final isHighContrast = Provider.of<SessionService>(
      context,
    ).highContrastEnabled;
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
        _topIcon(
          icon: Icons.home_outlined,
          active: currentRoute == '/dashboard',
          onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
          inactiveIconColor: inactiveIcon,
          isHighContrast: isHighContrast,
        ),
        _topIcon(
          icon: Icons.notifications_none_outlined,
          active: currentRoute == '/notifications',
          showDot: true,
          onTap: () => Navigator.pushReplacementNamed(context, '/notifications'),
          inactiveIconColor: inactiveIcon,
          isHighContrast: isHighContrast,
        ),
        _topIcon(
          icon: Icons.settings_outlined,
          active: currentRoute == '/settings',
          boxed: true,
          onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
          inactiveIconColor: inactiveIcon,
          isHighContrast: isHighContrast,
        ),
        _topIcon(
          icon: Icons.account_circle_outlined,
          active: currentRoute == '/profile',
          onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
          inactiveIconColor: inactiveIcon,
          isHighContrast: isHighContrast,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _topIcon({
    required IconData icon,
    required VoidCallback onTap,
    required Color inactiveIconColor,
    required bool isHighContrast,
    bool active = false,
    bool boxed = false,
    bool showDot = false,
  }) {
    final base = IconButton(
      onPressed: onTap,
      icon: Icon(
        icon,
        color: active ? const Color(0xFF2F80ED) : inactiveIconColor,
      ),
    );

    final wrapped = boxed
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 48,
            decoration: BoxDecoration(
              border: Border.all(
                color: isHighContrast ? Colors.white : const Color(0xFFD0D5DD),
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: base,
          )
        : base;

    if (!showDot) return wrapped;
    return Stack(
      children: [
        wrapped,
        const Positioned(
          top: 11,
          right: 11,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: Color(0xFFFF3347),
              shape: BoxShape.circle,
            ),
            child: SizedBox(width: 9, height: 9),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
