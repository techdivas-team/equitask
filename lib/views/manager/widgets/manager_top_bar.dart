import 'package:flutter/material.dart';

class ManagerTopBar extends StatelessWidget implements PreferredSizeWidget {
  final String currentRoute;

  const ManagerTopBar({super.key, required this.currentRoute});

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
        _icon(
          context,
          icon: Icons.home_outlined,
          route: '/manager/dashboard',
          active: currentRoute == '/manager/dashboard',
        ),
        _icon(
          context,
          icon: Icons.notifications_none_outlined,
          route: '/manager/notifications',
          active: currentRoute == '/manager/notifications',
          dot: true,
        ),
        _icon(
          context,
          icon: Icons.settings_outlined,
          route: '/manager/settings',
          active: currentRoute == '/manager/settings',
          boxed: true,
        ),
        _icon(
          context,
          icon: Icons.account_circle_outlined,
          route: '/manager/profile',
          active: currentRoute == '/manager/profile',
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
    bool boxed = false,
    bool dot = false,
  }) {
    final button = IconButton(
      onPressed: () => Navigator.pushReplacementNamed(context, route),
      icon: Icon(icon, color: active ? const Color(0xFF2F80ED) : const Color(0xFF344054)),
    );
    final widget = boxed
        ? Container(
            margin: const EdgeInsets.symmetric(vertical: 8),
            width: 48,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFD0D5DD)),
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
