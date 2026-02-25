import 'api_services.dart';
import 'http_api_service.dart';
import 'session_service.dart';

class AuthService {
  final ApiService _apiService;
  AppRole _lastRole = AppRole.manager;
  String? _lastOrganizationId;
  String? _lastEmail;
  String? _lastToken;

  AppRole get lastRole => _lastRole;
  String? get lastOrganizationId => _lastOrganizationId;
  String? get lastEmail => _lastEmail;
  String? get lastToken => _lastToken;

  AuthService(this._apiService);

  void _captureUser(Map<String, dynamic> response, {String? fallbackEmail}) {
    final user = response['user'];
    if (user is Map) {
      final role = (user['role'] ?? '').toString().toLowerCase();
      _lastRole = role == 'employee' ? AppRole.employee : AppRole.manager;
      _lastOrganizationId = user['organizationId']?.toString();
      _lastEmail = user['email']?.toString() ?? fallbackEmail;
      _lastToken = response['token']?.toString();
      return;
    }
    _lastRole = AppRole.manager;
    _lastEmail = fallbackEmail;
    _lastToken = response['token']?.toString();
  }

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
      'Request failed. Tried: $tried. Last error: ${lastError ?? 'unknown error'}',
    );
  }

  Future<bool> login(String email, String password) async {
    final response = await _apiService.post('/api/auth/login', {
      'email': email,
      'password': password,
    });
    _captureUser(response, fallbackEmail: email);
    if (response['token'] != null && _apiService is HttpApiService) {
      _apiService.setAuthToken(response['token'].toString());
    }
    return response['success'] == true;
  }

  Future<bool> signup(String name, String email, String password) async {
    return signupManager(name: name, email: email, password: password);
  }

  Future<bool> signupManager({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _postWithFallback([
      '/api/auth/register/manager',
      '/api/auth/register',
      '/api/auth/signup',
      '/auth/register',
    ], {
      'name': name,
      'email': email,
      'password': password,
    });
    _captureUser(response, fallbackEmail: email);
    if (response['token'] != null && _apiService is HttpApiService) {
      _apiService.setAuthToken(response['token'].toString());
    }
    return response['success'] == true;
  }

  Future<bool> validateInvitationCode(String invitationCode) async {
    final response = await _postWithFallback([
      '/api/invitations/validate',
      '/api/org/invitations/validate',
      '/api/auth/invitation/validate',
    ], {
      'invitationCode': invitationCode,
    });
    return response['success'] == true && response['isValid'] != false;
  }

  Future<bool> signupInvitedEmployee({
    required String name,
    required String email,
    required String password,
    required String invitationCode,
  }) async {
    final response = await _postWithFallback([
      '/api/auth/register/employee',
      '/api/auth/register/invited-employee',
      '/api/auth/register',
    ], {
      'name': name,
      'email': email,
      'password': password,
      'invitationCode': invitationCode,
    });
    _captureUser(response, fallbackEmail: email);
    if (response['token'] != null && _apiService is HttpApiService) {
      _apiService.setAuthToken(response['token'].toString());
    }
    return response['success'] == true;
  }

  Future<bool> signInWithGoogle() async {
    final response = await _apiService.post('/api/auth/google', {
      'mode': 'signin',
    });
    if (response['token'] != null && _apiService is HttpApiService) {
      _apiService.setAuthToken(response['token'].toString());
    }
    return response['success'] == true;
  }

  Future<bool> signUpWithGoogle() async {
    final response = await _apiService.post('/api/auth/google', {
      'mode': 'signup',
    });
    if (response['token'] != null && _apiService is HttpApiService) {
      _apiService.setAuthToken(response['token'].toString());
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
      _apiService.clearAuthToken();
    }
    await _apiService.post('/api/auth/logout', {});
  }
}
