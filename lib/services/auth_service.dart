import 'api_services.dart';
import 'http_api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<bool> login(String email, String password) async {
    final response = await _apiService.post('/login', {
      'email': email,
      'password': password,
    });
    if (_apiService is HttpApiService) {
      (_apiService as HttpApiService).setAuthToken(response['token']);
    }
    return response['success'] == true;
  }

  Future<bool> signup(String name, String email, String password) async {
    final response = await _apiService.post('/signup', {
      'name': name,
      'email': email,
      'password': password,
    });
    if (_apiService is HttpApiService) {
      (_apiService as HttpApiService).setAuthToken(response['token']);
    }
    return response['success'] == true;
  }

  Future<bool> forgotPassword(String email) async {
    final response = await _apiService.post('/forgot-password', {
      'email': email,
    });
    return response['success'] == true;
  }

  Future<void> logout() async {
    if (_apiService is HttpApiService) {
      (_apiService as HttpApiService).clearAuthToken();
    }
    await _apiService.post('/logout', {});
  }
}
