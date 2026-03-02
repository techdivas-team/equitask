import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../services/session_service.dart';
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
  bool _isSimplifying = false;
  String _filter = 'All';
  bool _isCreatingTask = false;

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

  Future<void> _showCreateTaskDialog() async {
    final formKey = GlobalKey<FormState>();
    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    DateTime? dueDate;
    TaskPriority priority = TaskPriority.important;

    await showDialog<void>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('Create New Task'),
              content: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      TextFormField(
                        controller: titleController,
                        decoration: const InputDecoration(labelText: 'Title'),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Title is required'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: descriptionController,
                        minLines: 3,
                        maxLines: 3,
                        decoration: const InputDecoration(
                          labelText: 'Description',
                        ),
                        validator: (value) => value == null || value.trim().isEmpty
                            ? 'Description is required'
                            : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<TaskPriority>(
                        initialValue: priority,
                        decoration: const InputDecoration(labelText: 'Priority'),
                        items: const [
                          DropdownMenuItem(
                            value: TaskPriority.urgent,
                            child: Text('High'),
                          ),
                          DropdownMenuItem(
                            value: TaskPriority.important,
                            child: Text('Medium'),
                          ),
                          DropdownMenuItem(
                            value: TaskPriority.normal,
                            child: Text('Low'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setDialogState(() => priority = value);
                        },
                      ),
                      const SizedBox(height: 10),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: context,
                              firstDate: DateTime.now(),
                              lastDate: DateTime(2035),
                              initialDate: dueDate ?? DateTime.now(),
                            );
                            if (picked == null) return;
                            setDialogState(() => dueDate = picked);
                          },
                          icon: const Icon(Icons.calendar_today_outlined),
                          label: Text(
                            dueDate == null
                                ? 'Choose due date'
                                : '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}',
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: _isCreatingTask ? null : () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                      onPressed: _isCreatingTask
                      ? null
                      : () async {
                          final navigator = Navigator.of(this.context);
                          final messenger = ScaffoldMessenger.of(this.context);
                          if (!formKey.currentState!.validate()) return;
                          if (dueDate == null) {
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Please choose a due date'),
                              ),
                            );
                            return;
                          }
                          setState(() => _isCreatingTask = true);
                          try {
                            await _taskService.createTask(
                              title: titleController.text.trim(),
                              description: descriptionController.text.trim(),
                              dueDate: dueDate!,
                              priority: priority,
                              status: 'not_started',
                            );
                            if (!mounted) return;
                            navigator.pop();
                            messenger.showSnackBar(
                              const SnackBar(
                                content: Text('Task created successfully'),
                              ),
                            );
                            await _loadTasks();
                          } catch (e) {
                            if (!mounted) return;
                            messenger.showSnackBar(
                              SnackBar(content: Text('Create task failed: $e')),
                            );
                          } finally {
                            if (mounted) {
                              setState(() => _isCreatingTask = false);
                            }
                          }
                        },
                  child: _isCreatingTask
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create'),
                ),
              ],
            );
          },
        );
      },
    );
    titleController.dispose();
    descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isHighContrast = Provider.of<SessionService>(
      context,
    ).highContrastEnabled;
    return Scaffold(
      backgroundColor: isHighContrast ? Colors.black : const Color(0xFFF3F5F7),
      appBar: const EmployeeTopBar(currentRoute: '/tasks'),
      drawer: const EmployeeDrawer(currentRoute: '/tasks'),
      floatingActionButton: const SupportFabStack(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadTasks,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 120),
                children: [
                  Align(
                    alignment: Alignment.centerRight,
                    child: ElevatedButton.icon(
                      onPressed: _showCreateTaskDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F80ED),
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.add),
                      label: const Text('New Task'),
                    ),
                  ),
                  const SizedBox(height: 10),
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
                      onFocusMode: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Focus mode is coming soon'),
                          ),
                        );
                      },
                      onSubmitProof: () => _handleSubmitProof(task),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
