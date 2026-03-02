import 'package:flutter/foundation.dart';

enum AccountMode { organization, individual }

enum AppRole { manager, employee }

class SessionService extends ChangeNotifier {
  bool _isAuthenticated = false;
  String? _token;
  String? _email;
  AppRole? _role;
  AccountMode _accountMode = AccountMode.organization;
  String? _organizationId;
  bool _hasValidInvite = false;
  bool _highContrastEnabled = false;
  bool _largeTextEnabled = false;
  bool _screenReaderAssistEnabled = false;
  bool _onboardingCompleted = false;

  bool get isAuthenticated => _isAuthenticated;
  String? get token => _token;
  String? get email => _email;
  AppRole? get role => _role;
  AccountMode get accountMode => _accountMode;
  String? get organizationId => _organizationId;
  bool get hasValidInvite => _hasValidInvite;
  bool get highContrastEnabled => _highContrastEnabled;
  bool get largeTextEnabled => _largeTextEnabled;
  bool get screenReaderAssistEnabled => _screenReaderAssistEnabled;
  bool get onboardingCompleted => _onboardingCompleted;

  void selectAccountMode(AccountMode mode) {
    _accountMode = mode;
    notifyListeners();
  }

  void setInviteState({required bool isValid, String? organizationId}) {
    _hasValidInvite = isValid;
    if (organizationId != null && organizationId.isNotEmpty) {
      _organizationId = organizationId;
    }
    notifyListeners();
  }

  void setAccessibilityOptions({
    required bool highContrast,
    required bool largeText,
    required bool screenReaderAssist,
  }) {
    _highContrastEnabled = highContrast;
    _largeTextEnabled = largeText;
    _screenReaderAssistEnabled = screenReaderAssist;
    notifyListeners();
  }

  void startSession({
    required String token,
    required String email,
    required AppRole role,
    String? organizationId,
  }) {
    _token = token;
    _email = email;
    _role = role;
    _organizationId = organizationId;
    _isAuthenticated = true;
    notifyListeners();
  }

  void clearSession() {
    _isAuthenticated = false;
    _token = null;
    _email = null;
    _role = null;
    _organizationId = null;
    _hasValidInvite = false;
    _highContrastEnabled = false;
    _largeTextEnabled = false;
    _screenReaderAssistEnabled = false;
    notifyListeners();
  }

  void completeOnboarding() {
    _onboardingCompleted = true;
    notifyListeners();
  }
}
