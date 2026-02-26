import 'api_services.dart';
import '../models/user.dart';

class UserService {
  final ApiService _apiService;
  UserService(this._apiService);

  Future<Map<String, dynamic>> _getWithFallback(List<String> endpoints) async {
    Exception? lastError;
    for (final endpoint in endpoints) {
      try {
        return await _apiService.get(endpoint);
      } on Exception catch (e) {
        lastError = e;
      }
    }
    throw Exception(lastError?.toString() ?? 'Request failed');
  }

  Future<void> _putWithFallback(
    List<String> endpoints,
    Map<String, dynamic> data,
  ) async {
    Exception? lastError;
    for (final endpoint in endpoints) {
      try {
        await _apiService.put(endpoint, data);
        return;
      } on Exception catch (e) {
        lastError = e;
      }
    }
    throw Exception(lastError?.toString() ?? 'Request failed');
  }

  Future<User> getCurrentUser() async {
    final response = await _getWithFallback([
      '/api/auth/me',
      '/api/users/me',
      '/me',
    ]);
    final userJson =
        response['user'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return User.fromJson(userJson);
  }

  Future<Map<String, bool>> getSettings() async {
    final response = await _getWithFallback([
      '/api/settings',
      '/settings',
      '/api/users/settings',
    ]);
    return {
      'pushNotifications': (response['pushNotifications'] as bool?) ?? true,
      'focusReminders': (response['focusReminders'] as bool?) ?? true,
      'highContrast': (response['highContrast'] as bool?) ?? false,
      'reduceMotion': (response['reduceMotion'] as bool?) ?? false,
    };
  }

  Future<void> updateSettings(Map<String, bool> settings) async {
    await _putWithFallback([
      '/api/settings',
      '/settings',
      '/api/users/settings',
    ], settings);
  }
}
