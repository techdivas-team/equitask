import 'package:flutter/material.dart';

class SupportFabStack extends StatelessWidget {
  final bool showClipboard;
  final VoidCallback? onAssistPressed;
  final VoidCallback? onClipboardPressed;

  const SupportFabStack({
    super.key,
    this.showClipboard = false,
    this.onAssistPressed,
    this.onClipboardPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            FloatingActionButton(
              heroTag: '${ModalRoute.of(context)?.settings.name}_assist',
              mini: true,
              backgroundColor: const Color(0xFF2F80ED),
              onPressed:
                  onAssistPressed ??
                  () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Accessibility quick actions are coming soon',
                        ),
                      ),
                    );
                  },
              child: const Icon(Icons.palette_outlined, color: Colors.white),
            ),
            if (showClipboard) ...[
              const SizedBox(height: 10),
              FloatingActionButton(
                heroTag: '${ModalRoute.of(context)?.settings.name}_clip',
                mini: true,
                backgroundColor: const Color(0xFF2F80ED),
                onPressed:
                    onClipboardPressed ??
                    () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Clipboard tools are coming soon'),
                        ),
                      );
                    },
                child: const Icon(Icons.assignment_outlined, color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
