import 'api_services.dart';
import 'http_api_service.dart';
import 'session_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

const String _googleWebClientId = String.fromEnvironment(
  'GOOGLE_WEB_CLIENT_ID',
  defaultValue:
      '995530463322-fqr9iqdk5mrf4lsbdua3bfqabbh2vi3k.apps.googleusercontent.com',
);

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

  bool _isAuthSuccess(Map<String, dynamic> response) {
    final payload = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;
    if (response['success'] == true || payload['success'] == true) {
      return true;
    }
    return _extractToken(response) != null ||
        payload['user'] != null ||
        response['user'] != null;
  }

  String? _extractToken(Map<String, dynamic> response) {
    final payload = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;
    return (payload['token'] ??
            response['token'] ??
            payload['accessToken'] ??
            response['accessToken'] ??
            payload['authToken'] ??
            response['authToken'])
        ?.toString();
  }

  void _captureUser(Map<String, dynamic> response, {String? fallbackEmail}) {
    final payload = response['data'] is Map<String, dynamic>
        ? response['data'] as Map<String, dynamic>
        : response;
    final user = payload['user'] ?? response['user'];
    if (user is Map) {
      final role = (user['role'] ?? '').toString().toLowerCase();
      _lastRole = role == 'employee' ? AppRole.employee : AppRole.manager;
      _lastOrganizationId = user['organizationId']?.toString();
      _lastEmail = user['email']?.toString() ?? fallbackEmail;
      _lastToken = _extractToken(response);
      return;
    }
    _lastRole = AppRole.manager;
    _lastEmail = fallbackEmail;
    _lastToken = _extractToken(response);
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

  Future<Map<String, dynamic>> _postWithEndpointAndBodyFallback(
    List<String> endpoints,
    List<Map<String, dynamic>> bodies,
  ) async {
    Exception? lastError;
    for (final body in bodies) {
      for (final endpoint in endpoints) {
        try {
          return await _apiService.post(endpoint, body);
        } on Exception catch (e) {
          lastError = e;
        }
      }
    }
    throw Exception(lastError?.toString() ?? 'Request failed');
  }

  Future<bool> login(String email, String password) async {
    final response = await _postWithFallback([
      '/api/auth/login',
      '/api/login',
      '/auth/login',
    ], {
      'email': email,
      'password': password,
    });
    _captureUser(response, fallbackEmail: email);
    final token = _lastToken;
    if (token != null && token.isNotEmpty && _apiService is HttpApiService) {
      _apiService.setAuthToken(token);
    }
    return _isAuthSuccess(response);
  }

  Future<bool> signup(String name, String email, String password) async {
    return signupManager(name: name, email: email, password: password);
  }

  Future<bool> signupManager({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _postWithEndpointAndBodyFallback(
      [
        '/api/auth/signup',
        '/api/auth/register',
        '/api/auth/register/manager',
        '/api/register',
        '/auth/register',
      ],
      [
        {
          'fullName': name,
          'name': name,
          'email': email,
          'password': password,
          'role': 'user',
        },
        {
          'fullName': name,
          'name': name,
          'email': email,
          'password': password,
          'role': 'manager',
        },
        {
          'fullName': name,
          'name': name,
          'email': email,
          'password': password,
        },
      ],
    );
    _captureUser(response, fallbackEmail: email);
    final token = _lastToken;
    if (token != null && token.isNotEmpty && _apiService is HttpApiService) {
      _apiService.setAuthToken(token);
    }
    return _isAuthSuccess(response);
  }

  Future<bool> validateInvitationCode(String invitationCode) async {
    final response = await _postWithFallback(
      [
        '/api/invitations/validate',
        '/api/org/invitations/validate',
        '/api/auth/invitation/validate',
      ],
      {'invitationCode': invitationCode},
    );
    return response['success'] == true && response['isValid'] != false;
  }

  Future<bool> signupInvitedEmployee({
    required String name,
    required String email,
    required String password,
    required String invitationCode,
  }) async {
    final response = await _postWithFallback(
      [
        '/api/auth/register/employee',
        '/api/auth/register/invited-employee',
        '/api/auth/register',
      ],
      {
        'name': name,
        'fullName': name,
        'email': email,
        'password': password,
        'invitationCode': invitationCode,
        'inviteCode': invitationCode,
        'role': 'employee',
      },
    );
    _captureUser(response, fallbackEmail: email);
    final token = _lastToken;
    if (token != null && token.isNotEmpty && _apiService is HttpApiService) {
      _apiService.setAuthToken(token);
    }
    return _isAuthSuccess(response);
  }

  Future<bool> signInWithGoogle() async {
    return _authenticateWithGoogle(mode: 'signin');
  }

  Future<bool> signUpWithGoogle() async {
    return _authenticateWithGoogle(mode: 'signup');
  }

  Future<bool> _authenticateWithGoogle({required String mode}) async {
    final googleSignIn = GoogleSignIn(
      scopes: const ['email', 'profile'],
      serverClientId: _googleWebClientId.isEmpty ? null : _googleWebClientId,
    );

    final account = await googleSignIn.signIn();
    if (account == null) {
      return false;
    }

    final authentication = await account.authentication;
    final idToken = authentication.idToken;
    if (kDebugMode) {
      debugPrint(
        'Google ID token available: ${idToken != null && idToken.isNotEmpty}',
      );
    }
    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Google ID token not available. Set GOOGLE_WEB_CLIENT_ID and verify app OAuth setup.',
      );
    }

    final response = await _apiService.post('/api/auth/google', {
      'mode': mode,
      'idToken': idToken,
      'email': account.email,
      'name': account.displayName,
    });

    _captureUser(response, fallbackEmail: account.email);
    final token = _lastToken;
    if (token != null && token.isNotEmpty && _apiService is HttpApiService) {
      _apiService.setAuthToken(token);
    }
    return _isAuthSuccess(response);
  }

  Future<bool> forgotPassword(String email) async {
    final response = await _postWithFallback([
      '/api/auth/forgot-password',
      '/api/forgot-password',
      '/auth/forgot-password',
    ], {
      'email': email,
    });
    return response['success'] == true;
  }

  Future<void> logout() async {
    Exception? lastError;
    for (final endpoint in [
      '/api/auth/logout',
      '/api/logout',
      '/auth/logout',
    ]) {
      try {
        await _apiService.post(endpoint, {});
        break;
      } on Exception catch (e) {
        lastError = e;
      }
    }

    if (_apiService is HttpApiService) {
      _apiService.clearAuthToken();
    }
    _lastToken = null;
    _lastEmail = null;
    _lastOrganizationId = null;
    _lastRole = AppRole.manager;
    if (lastError != null && kDebugMode) {
      debugPrint('Logout endpoint warning: $lastError');
    }
  }
}
