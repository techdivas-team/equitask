import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/user_service.dart';
import '../employee/widgets/support_fab_stack.dart';
import 'manager_drawer.dart';
import 'widgets/manager_top_bar.dart';

class ManagerSettingsScreen extends StatefulWidget {
  const ManagerSettingsScreen({super.key});

  @override
  State<ManagerSettingsScreen> createState() => _ManagerSettingsScreenState();
}

class _ManagerSettingsScreenState extends State<ManagerSettingsScreen> {
  late final UserService _userService;
  Map<String, bool> _settings = {};
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _userService = Provider.of<UserService>(context);
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    setState(() => _isLoading = true);
    try {
      final data = await _userService.getSettings();
      if (!mounted) return;
      setState(() {
        _settings = data;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);
    try {
      await _userService.updateSettings(_settings);
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Settings saved')));
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Failed to save settings')));
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: const ManagerTopBar(currentRoute: '/manager/settings'),
      drawer: const ManagerDrawer(currentRoute: '/manager/settings'),
      floatingActionButton: const SupportFabStack(showClipboard: true),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
              children: [
                _switchTile(
                  title: 'Push Notifications',
                  subtitle: 'Receive notifications about tasks and reminders.',
                  value: _settings['pushNotifications'] ?? true,
                  onChanged: (value) =>
                      setState(() => _settings['pushNotifications'] = value),
                ),
                _switchTile(
                  title: 'Focus Reminders',
                  subtitle: 'Get reminders to complete in-progress tasks.',
                  value: _settings['focusReminders'] ?? true,
                  onChanged: (value) =>
                      setState(() => _settings['focusReminders'] = value),
                ),
                _switchTile(
                  title: 'High Contrast',
                  subtitle: 'Improve visual contrast for accessibility.',
                  value: _settings['highContrast'] ?? false,
                  onChanged: (value) =>
                      setState(() => _settings['highContrast'] = value),
                ),
                _switchTile(
                  title: 'Reduce Motion',
                  subtitle: 'Limit animation and motion effects.',
                  value: _settings['reduceMotion'] ?? false,
                  onChanged: (value) =>
                      setState(() => _settings['reduceMotion'] = value),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  height: 48,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveSettings,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2F80ED),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
                            'Save Settings',
                            style: TextStyle(fontWeight: FontWeight.w600),
                          ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _switchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFD8DDE6)),
      ),
      child: SwitchListTile(
        value: value,
        onChanged: onChanged,
        activeThumbColor: const Color(0xFF2F80ED),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF15283B),
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: Color(0xFF6B7280),
          ),
        ),
      ),
    );
  }
}
