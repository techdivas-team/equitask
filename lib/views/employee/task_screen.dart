import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../services/session_service.dart';
import '../../services/task_service.dart';
import '../manager/manager_drawer.dart';
import '../manager/widgets/manager_top_bar.dart';
import 'employee_drawer.dart';
import 'widgets/employee_top_bar.dart';
import 'widgets/support_fab_stack.dart';
import 'widgets/task_card.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  late final TaskService _taskService;
  List<Task> _tasks = [];
  bool _isLoading = true;
  bool _isSimplifying = false;
  String _filter = 'All';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _taskService = Provider.of<TaskService>(context);
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _isLoading = true);
    try {
      final tasks = await _taskService.getTasks();
      if (!mounted) return;
      setState(() {
        _tasks = tasks;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _isLoading = false);
    }
  }

  List<Task> get _visibleTasks {
    if (_filter == 'All') return _tasks;
    return _tasks
        .where((t) => t.status.toLowerCase() == _filter.toLowerCase())
        .toList();
  }

  Future<void> _handleSimplifyTask(Task task) async {
    if (_isSimplifying) return;
    setState(() => _isSimplifying = true);
    try {
      final simplified = await _taskService.simplifyTaskDescription(
        taskDescription: task.description,
        level: 'simple',
      );
      if (!mounted) return;
      _showSimplifyResult(task.title, simplified);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Simplify failed: $e')));
    } finally {
      if (mounted) setState(() => _isSimplifying = false);
    }
  }

  Future<void> _showSimplifyResult(String title, String result) async {
    await showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Simplified: $title'),
          content: SingleChildScrollView(child: Text(result)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Close'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSubmitProof(Task task) async {
    final result = await FilePicker.platform.pickFiles(withData: true);
    if (result == null || result.files.isEmpty) return;

    final file = result.files.single;
    try {
      await _taskService.submitProofFile(
        taskId: task.id,
        fileName: file.name,
        filePath: file.path,
        fileBytes: file.bytes,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Proof uploaded for "${task.title}"')),
      );
      await _loadTasks();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Proof upload failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final session = Provider.of<SessionService>(context);
    final isIndividual = session.accountMode == AccountMode.individual;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: isIndividual
          ? const ManagerTopBar(currentRoute: '/tasks')
          : const EmployeeTopBar(currentRoute: '/tasks'),
      drawer: isIndividual
          ? const ManagerDrawer(currentRoute: '/tasks')
          : const EmployeeDrawer(currentRoute: '/tasks'),
      floatingActionButton: const SupportFabStack(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                children: [
                  Wrap(
                    spacing: 8,
                    children: ['All', 'Pending', 'In progress']
                        .map(
                          (item) => ChoiceChip(
                            label: Text(item),
                            selected: _filter == item,
                            onSelected: (_) => setState(() => _filter = item),
                            selectedColor: const Color(0xFFDCEBFF),
                            labelStyle: TextStyle(
                              color: _filter == item
                                  ? const Color(0xFF1E5BB8)
                                  : const Color(0xFF4B5563),
                            ),
                          ),
                        )
                        .toList(),
                  ),
                  const SizedBox(height: 14),
                  if (_visibleTasks.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.only(top: 40),
                        child: Text(
                          'No tasks for this filter',
                          style: TextStyle(color: Color(0xFF6B7280)),
                        ),
                      ),
                    ),
                  ..._visibleTasks.map(
                    (task) => TaskCard(
                      task: task,
                      onSimplify: () => _handleSimplifyTask(task),
                      onFocusMode: () {},
                      onSubmitProof: () => _handleSubmitProof(task),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
