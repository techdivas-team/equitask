import 'api_services.dart';
import '../models/user.dart';

class UserService {
  final ApiService _apiService;
  UserService(this._apiService);

  Future<User> getCurrentUser() async {
    final response = await _apiService.get('/api/auth/me');
    final userJson =
        response['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return User.fromJson(userJson);
  }

  Future<Map<String, bool>> getSettings() async {
    final response = await _apiService.get('/settings');
    return {
      'pushNotifications': (response['pushNotifications'] as bool?) ?? true,
      'focusReminders': (response['focusReminders'] as bool?) ?? true,
      'highContrast': (response['highContrast'] as bool?) ?? false,
      'reduceMotion': (response['reduceMotion'] as bool?) ?? false,
    };
  }

  Future<void> updateSettings(Map<String, bool> settings) async {
    await _apiService.put('/settings', settings);
  }
}
