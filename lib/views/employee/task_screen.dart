import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: const EmployeeTopBar(currentRoute: '/tasks'),
      drawer: const EmployeeDrawer(currentRoute: '/tasks'),
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
                      onSimplify: () {},
                      onFocusMode: () {},
                      onSubmitProof: () {},
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
