import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/app_notification.dart';
import '../../services/notification_service.dart';

class NotificationsContent extends StatefulWidget {
  const NotificationsContent({super.key});

  @override
  State<NotificationsContent> createState() => _NotificationsContentState();
}

class _NotificationsContentState extends State<NotificationsContent> {
  late final NotificationService _notificationService;
  List<AppNotification> _notifications = [];
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _notificationService = Provider.of<NotificationService>(context);
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final data = await _notificationService.getNotifications();
      if (!mounted) return;
      setState(() {
        _notifications = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _markAllRead() async {
    await _notificationService.markAllRead();
    if (!mounted) return;
    setState(() {
      _notifications = _notifications
          .map(
            (n) => AppNotification(
              id: n.id,
              title: n.title,
              message: n.message,
              timestamp: n.timestamp,
              isRead: true,
            ),
          )
          .toList();
    });
  }

  Future<void> _deleteNotification(AppNotification notification) async {
    try {
      await _notificationService.deleteNotification(notification.id);
    } catch (_) {
      // Keep optimistic UI behavior even if backend route is unavailable.
    }
    if (!mounted) return;
    setState(() {
      _notifications.removeWhere((n) => n.id == notification.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    final unreadCount = _notifications.where((n) => !n.isRead).length;
    return RefreshIndicator(
      onRefresh: _loadNotifications,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
        children: [
          Row(
            children: [
              const Text(
                'Notifications',
                style: TextStyle(
                  color: Color(0xFF15283B),
                  fontWeight: FontWeight.w700,
                  fontSize: 18,
                ),
              ),
              const SizedBox(width: 10),
              Text(
                '$unreadCount unread',
                style: const TextStyle(color: Color(0xFF6B7280), fontSize: 13),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: unreadCount == 0 ? null : _markAllRead,
                icon: const Icon(Icons.done_all),
                label: const Text('Mark All Read'),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ..._notifications.map((item) {
            return Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: item.isRead
                    ? const Color(0xFFF7FAFF)
                    : const Color(0xFFF0FBF5),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: item.isRead
                      ? const Color(0xFFD8E8FF)
                      : const Color(0xFFC9EDD8),
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 4),
                    width: 9,
                    height: 9,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: item.isRead
                          ? const Color(0xFF3B82F6)
                          : const Color(0xFF22C55E),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          item.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: item.isRead
                                ? FontWeight.w600
                                : FontWeight.w700,
                            color: const Color(0xFF15283B),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          item.message,
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _formatTimeLabel(item.timestamp),
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF9CA3AF),
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => _deleteNotification(item),
                    icon: const Icon(
                      Icons.delete_outline,
                      color: Color(0xFFDC2626),
                    ),
                    tooltip: 'Delete notification',
                  ),
                ],
              ),
            );
          }),
        ],
      ),
    );
  }

  String _formatTimeLabel(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    final local = dateTime.toLocal();
    final minute = local.minute.toString().padLeft(2, '0');

    if (diff.inMinutes < 1) return 'Just now - ${local.hour}:$minute';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago - ${local.hour}:$minute';
    if (diff.inHours < 24) return '${diff.inHours}h ago - ${local.hour}:$minute';
    if (diff.inDays < 7) return '${diff.inDays}d ago - ${local.hour}:$minute';
    return '${local.day}/${local.month}/${local.year} ${local.hour}:$minute';
  }
}
