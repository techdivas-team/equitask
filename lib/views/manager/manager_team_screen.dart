import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/team_service.dart';
import '../employee/widgets/support_fab_stack.dart';
import 'manager_drawer.dart';
import 'widgets/manager_top_bar.dart';

class ManagerTeamScreen extends StatefulWidget {
  const ManagerTeamScreen({super.key});

  @override
  State<ManagerTeamScreen> createState() => _ManagerTeamScreenState();
}

class _ManagerTeamScreenState extends State<ManagerTeamScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final teamService = Provider.of<TeamService>(context);
    final query = _searchController.text.trim().toLowerCase();
    final members = teamService.members
        .where((m) => m.name.toLowerCase().contains(query) || m.email.toLowerCase().contains(query))
        .toList();

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: const ManagerTopBar(currentRoute: '/manager/team'),
      drawer: const ManagerDrawer(currentRoute: '/manager/team'),
      floatingActionButton: const SupportFabStack(showClipboard: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Team\nManagement', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF15283B))),
                    SizedBox(height: 4),
                    Text(
                      'Manage your team members and invitation access',
                      style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                    ),
                  ],
                ),
              ),
              ElevatedButton.icon(
                onPressed: _showInviteDialog,
                icon: const Icon(Icons.person_add_alt_1_outlined, color: Colors.white),
                label: const Text('Invite Member', style: TextStyle(color: Colors.white)),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F80ED)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          _simpleMetric('Team Members', '${teamService.members.length}', Icons.groups_2_outlined),
          const SizedBox(height: 10),
          _simpleMetric('Total Tasks', '${teamService.totalAssignedTasks}', Icons.bar_chart_outlined),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFD8DDE6)),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(
                hintText: 'Search team members...',
                prefixIcon: Icon(Icons.search),
              ),
            ),
          ),
          const SizedBox(height: 12),
          ...members.map(_memberCard),
          if (teamService.invites.isNotEmpty) ...[
            const SizedBox(height: 10),
            const Text(
              'Recent Invites',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF15283B)),
            ),
            const SizedBox(height: 8),
            ...teamService.invites.take(3).map(_inviteCard),
          ],
        ],
      ),
    );
  }

  Widget _simpleMetric(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8DDE6)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: const Color(0xFF2F80ED), size: 34),
          const SizedBox(height: 12),
          Text(label, style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280))),
          const SizedBox(height: 8),
          Text(value, style: const TextStyle(fontSize: 24, color: Color(0xFF15283B))),
        ],
      ),
    );
  }

  Widget _memberCard(TeamMember member) {
    final initials = member.name
        .split(' ')
        .where((part) => part.isNotEmpty)
        .take(2)
        .map((s) => s[0])
        .join();
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFD8DDE6)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: const Color(0xFFE8F3EE),
                child: Text(initials, style: const TextStyle(fontSize: 22, color: Color(0xFF1F2937))),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(member.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF15283B))),
                    const SizedBox(height: 4),
                    Text(member.email, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    Text(member.phone, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                    Text(member.location, style: const TextStyle(fontSize: 13, color: Color(0xFF6B7280))),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                decoration: BoxDecoration(border: Border.all(color: const Color(0xFFD1D5DB)), borderRadius: BorderRadius.circular(10)),
                child: const Text('Active'),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: const Color(0xFFF6F7FB), borderRadius: BorderRadius.circular(10)),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _stat('Assigned', '${member.assignedTasks}'),
                _stat('Completed', '${member.completedTasks}'),
                _stat('Rate', '${(member.completionRate * 100).round()}%'),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(onPressed: () {}, child: const Text('View Tasks')),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => Navigator.pushNamed(context, '/manager/create-task'),
                  style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F80ED)),
                  child: const Text('Assign Task', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _inviteCard(TeamInvite invite) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFFD8DDE6)),
      ),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFFEAF3FF),
            child: Icon(Icons.mail_outline, color: Color(0xFF2F80ED)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(invite.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(invite.email, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
                Text('Code: ${invite.inviteCode}', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Text(invite.status, style: const TextStyle(color: Color(0xFF2F80ED))),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Color(0xFF6B7280))),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF15283B))),
      ],
    );
  }

  Future<void> _showInviteDialog() async {
    final invite = await showDialog<TeamInvite>(
      context: context,
      barrierDismissible: true,
      builder: (_) => const _InviteMemberDialog(),
    );

    if (invite == null || !mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Invite sent to ${invite.email}. Code: ${invite.inviteCode}',
        ),
      ),
    );
  }
}

class _InviteMemberDialog extends StatefulWidget {
  const _InviteMemberDialog();

  @override
  State<_InviteMemberDialog> createState() => _InviteMemberDialogState();
}

class _InviteMemberDialogState extends State<_InviteMemberDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  String _role = 'Employee';
  bool _submitting = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendInvite() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _submitting = true);
    try {
      final teamService = Provider.of<TeamService>(context, listen: false);
      final invite = await teamService.sendInvite(
        name: _nameController.text.trim(),
        email: _emailController.text.trim(),
        role: _role,
      );
      if (!mounted) return;
      Navigator.pop(context, invite);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  const CircleAvatar(
                    backgroundColor: Color(0xFFE8F3EE),
                    child: Icon(
                      Icons.person_add_alt_1_outlined,
                      color: Color(0xFF2F80ED),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Invite Team\nMember',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF15283B),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.close),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Send an invitation to add a new team member to your workspace',
                style: TextStyle(color: Color(0xFF6B7280)),
              ),
              const SizedBox(height: 14),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Full Name',
                  hintText: 'Enter full name',
                ),
                validator: (value) =>
                    value == null || value.trim().isEmpty
                        ? 'Name is required'
                        : null,
              ),
              const SizedBox(height: 10),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: 'Email Address',
                  hintText: 'email@company.com',
                ),
                validator: (value) =>
                    value == null || !value.contains('@')
                        ? 'Valid email is required'
                        : null,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _roleCard(
                      'Employee',
                      _role == 'Employee',
                      () => setState(() => _role = 'Employee'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _roleCard(
                      'Manager',
                      _role == 'Manager',
                      () => setState(() => _role = 'Manager'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _submitting
                          ? null
                          : () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _submitting ? null : _sendInvite,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F80ED),
                      ),
                      icon: const Icon(Icons.mail_outline, color: Colors.white),
                      label: Text(
                        _submitting ? 'Sending...' : 'Send Invite',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _roleCard(String text, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 14),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFE8F3EE) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFF2F80ED) : const Color(0xFFD8DDE6),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: const TextStyle(fontSize: 16, color: Color(0xFF1F2937)),
          ),
        ),
      ),
    );
  }
}
