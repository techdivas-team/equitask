import 'api_services.dart';
import 'http_api_service.dart';

class AuthService {
  final ApiService _apiService;

  AuthService(this._apiService);

  Future<Map<String, dynamic>> _postWithFallback(
    List<String> endpoints,
    Map<String, dynamic> body,
  ) async {
    Exception? lastError;

    for (final endpoint in endpoints) {
      try {
        return await _apiService.post(endpoint, body);
      } on Exception catch (e) {
        lastError = e;
      }
    }

    final tried = endpoints.join(', ');
    throw Exception(
      'Signup route not found. Tried: $tried. Last error: ${lastError ?? 'unknown error'}',
    );
  }

  Future<bool> login(String email, String password) async {
    final response = await _apiService.post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    if (response['token'] != null && _apiService is HttpApiService) {
      (_apiService as HttpApiService).setAuthToken(
        response['token'].toString(),
      );
    }
    return response['success'] == true;
  }

  Future<bool> signup(String name, String email, String password) async {
    final response = await _postWithFallback([
      '/api/auth/register',
      '/api/auth/signup',
      '/auth/register',
    ], {
      'name': name,
      'email': email,
      'password': password,
    });
    if (response['token'] != null && _apiService is HttpApiService) {
      (_apiService as HttpApiService).setAuthToken(
        response['token'].toString(),
      );
    }
    return response['success'] == true;
  }

  Future<bool> signInWithGoogle() async {
    final response = await _apiService.post('/api/auth/google', {
      'mode': 'signin',
    });
    if (response['token'] != null && _apiService is HttpApiService) {
      (_apiService as HttpApiService).setAuthToken(
        response['token'].toString(),
      );
    }
    return response['success'] == true;
  }

  Future<bool> signUpWithGoogle() async {
    final response = await _apiService.post('/api/auth/google', {
      'mode': 'signup',
    });
    if (response['token'] != null && _apiService is HttpApiService) {
      (_apiService as HttpApiService).setAuthToken(
        response['token'].toString(),
      );
    }
    return response['success'] == true;
  }

  Future<bool> forgotPassword(String email) async {
    final response = await _apiService.post('/api/auth/forgot-password', {
      'email': email,
    });
    return response['success'] == true;
  }

  Future<void> logout() async {
    if (_apiService is HttpApiService) {
      (_apiService as HttpApiService).clearAuthToken();
    }
    await _apiService.post('/api/auth/logout', {});
  }
}
