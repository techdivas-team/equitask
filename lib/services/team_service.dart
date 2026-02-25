import 'dart:math';
import 'package:flutter/foundation.dart';

class TeamMember {
  final String id;
  final String name;
  final String email;
  final String role;
  final String phone;
  final String location;
  final int assignedTasks;
  final int completedTasks;

  const TeamMember({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.phone,
    required this.location,
    required this.assignedTasks,
    required this.completedTasks,
  });

  double get completionRate =>
      assignedTasks == 0 ? 0 : (completedTasks / assignedTasks);
}

class TeamInvite {
  final String id;
  final String name;
  final String email;
  final String role;
  final String inviteCode;
  final DateTime createdAt;
  final String status;

  const TeamInvite({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    required this.inviteCode,
    required this.createdAt,
    required this.status,
  });
}

class TeamService extends ChangeNotifier {
  final List<TeamMember> _members = const [
    TeamMember(
      id: 'tm_1',
      name: 'Sarah Johnson',
      email: 'sarah.j@company.com',
      role: 'Employee',
      phone: '+1 (555) 123-4567',
      location: 'San Francisco, CA',
      assignedTasks: 8,
      completedTasks: 6,
    ),
    TeamMember(
      id: 'tm_2',
      name: 'Michael Chen',
      email: 'michael.c@company.com',
      role: 'Employee',
      phone: '+1 (555) 234-5678',
      location: 'New York, NY',
      assignedTasks: 11,
      completedTasks: 9,
    ),
  ];

  final List<TeamInvite> _invites = [];

  List<TeamMember> get members => List.unmodifiable(_members);
  List<TeamInvite> get invites => List.unmodifiable(_invites);

  int get totalAssignedTasks =>
      _members.fold<int>(0, (sum, m) => sum + m.assignedTasks);

  int get totalCompletedTasks =>
      _members.fold<int>(0, (sum, m) => sum + m.completedTasks);

  Future<TeamInvite> sendInvite({
    required String name,
    required String email,
    required String role,
  }) async {
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
  }

  String _generateCode() {
    final random = Random();
    final tail = 1000 + random.nextInt(9000);
    return 'EQT-INV-$tail';
  }
}
