import 'package:flutter/material.dart';

class SupportFabStack extends StatelessWidget {
  final bool showClipboard;

  const SupportFabStack({super.key, this.showClipboard = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        FloatingActionButton(
          heroTag: '${ModalRoute.of(context)?.settings.name}_assist',
          mini: false,
          backgroundColor: const Color(0xFF2F80ED),
          onPressed: () {},
          child: const Icon(Icons.palette_outlined, color: Colors.white),
        ),
        if (showClipboard) ...[
          const SizedBox(height: 12),
          FloatingActionButton(
            heroTag: '${ModalRoute.of(context)?.settings.name}_clip',
            mini: false,
            backgroundColor: const Color(0xFF2F80ED),
            onPressed: () {},
            child: const Icon(Icons.assignment_outlined, color: Colors.white),
          ),
        ],
      ],
    );
  }
}
