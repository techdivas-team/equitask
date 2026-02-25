import 'package:flutter/material.dart';

class EmployeeTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;

  const EmployeeTopBar({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      leading: Builder(
        builder: (context) => IconButton(
          onPressed: () => Scaffold.of(context).openDrawer(),
          icon: const Icon(Icons.menu, color: Color(0xFF344054)),
        ),
      ),
      actions: [
        _topIcon(
          icon: Icons.home_outlined,
          active: currentRoute == '/dashboard',
          onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
        ),
        _topIcon(
          icon: Icons.notifications_none_outlined,
          active: currentRoute == '/notifications',
          showDot: true,
          onTap: () => Navigator.pushReplacementNamed(context, '/notifications'),
        ),
        _topIcon(
          icon: Icons.settings_outlined,
          active: currentRoute == '/settings',
          boxed: true,
          onTap: () => Navigator.pushReplacementNamed(context, '/settings'),
        ),
        _topIcon(
          icon: Icons.account_circle_outlined,
          active: currentRoute == '/profile',
          onTap: () => Navigator.pushReplacementNamed(context, '/profile'),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _topIcon({
    required IconData icon,
    required VoidCallback onTap,
    bool active = false,
    bool boxed = false,
    bool showDot = false,
  }) {
    final base = IconButton(
      onPressed: onTap,
      icon: Icon(icon, color: active ? const Color(0xFF2F80ED) : const Color(0xFF344054)),
    );

    final wrapped = boxed
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 48,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD0D5DD)),
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
            decoration: BoxDecoration(color: Color(0xFFFF3347), shape: BoxShape.circle),
            child: SizedBox(width: 9, height: 9),
          ),
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
