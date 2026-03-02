import 'api_services.dart';
import '../models/app_notification.dart';

class NotificationService {
  final ApiService _apiService;
  NotificationService(this._apiService);

  Future<Map<String, dynamic>> _getWithFallback(List<String> endpoints) async {
    Exception? lastError;
    for (final endpoint in endpoints) {
      try {
        return await _apiService.get(endpoint);
      } on Exception catch (e) {
        lastError = e;
      }
    }
    throw Exception(lastError?.toString() ?? 'Notification fetch failed');
  }

  Future<List<AppNotification>> getNotifications() async {
    final response = await _getWithFallback([
      '/api/notifications',
      '/notifications',
    ]);
    final notifications = (response['notifications'] as List<dynamic>? ?? []);
    return notifications
        .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAllRead() async {
    try {
      await _apiService.post('/api/notifications/mark-all-read', {});
    } on Exception {
      await _apiService.post('/notifications/mark-all-read', {});
    }
  }

  Future<void> markAsRead(String id) async {
    try {
      await _apiService.patch('/api/notifications/$id/read', {'isRead': true});
    } on Exception {
      await _apiService.patch('/notifications/$id/read', {'isRead': true});
    }
  }

  Future<void> deleteNotification(String id) async {
    try {
      await _apiService.delete('/api/notifications/$id');
    } on Exception {
      await _apiService.delete('/notifications/$id');
    }
  }
}
