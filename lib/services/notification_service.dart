import 'api_services.dart';
import '../models/app_notification.dart';

class NotificationService {
  final ApiService _apiService;
  NotificationService(this._apiService);

  Future<List<AppNotification>> getNotifications() async {
    final response = await _apiService.get('/notifications');
    final notifications = (response['notifications'] as List<dynamic>? ?? []);
    return notifications
        .map((item) => AppNotification.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<void> markAllRead() async {
    await _apiService.post('/notifications/mark-all-read', {});
  }
}
