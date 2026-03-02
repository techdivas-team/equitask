import 'dart:math';
import 'package:flutter/foundation.dart';
import 'api_services.dart';

class TeamMember {
  final String id;
  final String name;
  final String email;
  final String role;
  final String? phone;
  final String? location;
  final int assignedTasks;
  final int completedTasks;
  final bool isActive;

  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone,
    this.location,
    this.assignedTasks = 0,
    this.completedTasks = 0,
    this.isActive = true,
  });

  double get completionRate =>
      assignedTasks == 0 ? 0 : (completedTasks / assignedTasks);

  factory TeamMember.fromJson(Map<String, dynamic> json) {
    return TeamMember(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: (json['name'] ?? json['fullName'] ?? '').toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'employee').toString(),
      phone: json['phone']?.toString(),
      location: json['location']?.toString(),
      assignedTasks: json['assignedTasks'] as int? ?? 0,
      completedTasks: json['completedTasks'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }
}

class TeamInvite {
  final String id;
  final String? name;
  final String email;
  final String role;
  final String inviteCode;
  final DateTime createdAt;
  final String status;

  const TeamInvite({
    required this.id,
    this.name,
    required this.email,
    required this.role,
    required this.inviteCode,
    required this.createdAt,
    required this.status,
  });

  factory TeamInvite.fromJson(Map<String, dynamic> json) {
    final rawCreatedAt = json['createdAt']?.toString();
    return TeamInvite(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      name: json['name']?.toString(),
      email: (json['email'] ?? '').toString(),
      role: (json['role'] ?? 'employee').toString(),
      inviteCode: (json['inviteCode'] ?? json['code'] ?? '').toString(),
      createdAt: rawCreatedAt != null
          ? DateTime.tryParse(rawCreatedAt) ?? DateTime.now()
          : DateTime.now(),
      status: (json['status'] ?? 'pending').toString(),
    );
  }
}

class TeamService extends ChangeNotifier {
  final ApiService _apiService;
  List<TeamMember> _members = [];
  List<TeamInvite> _invites = [];
  bool _isLoading = false;

  // Polling for real-time updates
  static const Duration _pollingInterval = Duration(seconds: 30);
  bool _pollingEnabled = false;

  TeamService(this._apiService);

  List<TeamMember> get members => List.unmodifiable(_members);
  List<TeamInvite> get invites => List.unmodifiable(_invites);
  bool get isLoading => _isLoading;

  int get totalAssignedTasks =>
      _members.fold<int>(0, (sum, m) => sum + m.assignedTasks);

  int get totalCompletedTasks =>
      _members.fold<int>(0, (sum, m) => sum + m.completedTasks);

  /// Start polling for real-time updates
  void startPolling() {
    _pollingEnabled = true;
    _poll();
  }

  /// Stop polling
  void stopPolling() {
    _pollingEnabled = false;
  }

  Future<void> _poll() async {
    while (_pollingEnabled) {
      await Future.delayed(_pollingInterval);
      if (_pollingEnabled) {
        await Future.wait([fetchMembers(), fetchInvites()]);
      }
    }
  }

  /// Fetch team members from API
  Future<void> fetchMembers() async {
    try {
      final response = await _apiService.get('/api/org/members');
      final membersJson =
          response['members'] as List<dynamic>? ??
          response['data'] as List<dynamic>? ??
          [];
      _members = membersJson
          .map((json) => TeamMember.fromJson(json as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching members: $e');
    }
  }

  /// Fetch pending invites from API
  Future<void> fetchInvites() async {
    try {
      final response = await _apiService.get('/api/org/invites');
      final invitesJson =
          response['invites'] as List<dynamic>? ??
          response['data'] as List<dynamic>? ??
          [];
      _invites = invitesJson
          .map((json) => TeamInvite.fromJson(json as Map<String, dynamic>))
          .toList();
      notifyListeners();
    } catch (e) {
      debugPrint('Error fetching invites: $e');
    }
  }

  /// Send invite to a team member
  Future<TeamInvite> sendInvite({
    required String email,
    required String role,
    String? name,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _apiService.post('/api/org/invite', {
        'email': email,
        'role': role,
        if (name != null) 'name': name,
      });

      final inviteJson = response['invite'] ?? response['data'] ?? response;
      final invite = TeamInvite.fromJson(inviteJson);

      _invites.insert(0, invite);
      notifyListeners();
      return invite;
    } catch (e) {
      // If API fails, create a local invite for demo purposes
      debugPrint('Invite API failed, using local fallback: $e');
      final code = _generateCode();
      final invite = TeamInvite(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: name,
        email: email,
        role: role,
        inviteCode: code,
        createdAt: DateTime.now(),
        status: 'Pending',
      );
      _invites.insert(0, invite);
      notifyListeners();
      return invite;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Validate an invite code
  Future<Map<String, dynamic>> validateInviteCode(String code) async {
    final response = await _apiService.get('/api/org/invite/$code');
    return {
      'isValid': response['isValid'] ?? response['success'] ?? true,
      'organizationId': response['organizationId']?.toString(),
      'organizationName': response['organizationName']?.toString(),
    };
  }

  /// Cancel/revoke an invite
  Future<void> cancelInvite(String inviteId) async {
    await _apiService.delete('/api/org/invite/$inviteId');
    _invites.removeWhere((invite) => invite.id == inviteId);
    notifyListeners();
  }

  /// Remove a team member
  Future<void> removeMember(String memberId) async {
    await _apiService.delete('/api/org/members/$memberId');
    _members.removeWhere((member) => member.id == memberId);
    notifyListeners();
  }

  /// Generate invite code (fallback for mock)
  String _generateCode() {
    final random = Random();
    final tail = 1000 + random.nextInt(9000);
    return 'EQT-INV-$tail';
  }
}
