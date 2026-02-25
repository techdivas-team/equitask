import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../employee/widgets/support_fab_stack.dart';
import 'manager_drawer.dart';
import 'widgets/manager_top_bar.dart';

class ManagerCreateTaskScreen extends StatefulWidget {
  const ManagerCreateTaskScreen({super.key});

  @override
  State<ManagerCreateTaskScreen> createState() => _ManagerCreateTaskScreenState();
}

class _ManagerCreateTaskScreenState extends State<ManagerCreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _dueDateController = TextEditingController();
  final List<TextEditingController> _microSteps = [TextEditingController()];
  String _priority = 'Medium Priority';
  String _assignee = 'Sarah Johnson';
  DateTime? _selectedDueDate;
  bool _isSubmitting = false;

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _dueDateController.dispose();
    for (final c in _microSteps) {
      c.dispose();
    }
    super.dispose();
  }

  TaskPriority get _mappedPriority {
    switch (_priority) {
      case 'High Priority':
        return TaskPriority.urgent;
      case 'Low Priority':
        return TaskPriority.normal;
      default:
        return TaskPriority.important;
    }
  }

  Future<void> _pickDueDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: DateTime.now(),
      lastDate: DateTime(2030),
      initialDate: _selectedDueDate ?? DateTime.now(),
    );
    if (picked == null) return;
    setState(() {
      _selectedDueDate = picked;
      _dueDateController.text =
          '${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}';
    });
  }

  Future<void> _handleCreateTask() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedDueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a due date')),
      );
      return;
    }

    setState(() => _isSubmitting = true);
    try {
      final taskService = Provider.of<TaskService>(context, listen: false);
      await taskService.createTask(
        title: _titleController.text.trim(),
        description: _descriptionController.text.trim(),
        dueDate: _selectedDueDate!,
        priority: _mappedPriority,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Task created successfully')),
      );
      Navigator.pushReplacementNamed(context, '/manager/analytics');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to create task: $e')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: const ManagerTopBar(currentRoute: '/manager/create-task'),
      drawer: const ManagerDrawer(currentRoute: '/manager/create-task'),
      floatingActionButton: const SupportFabStack(showClipboard: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
          children: [
            const Row(
              children: [
                Icon(Icons.add, size: 38, color: Color(0xFF2F80ED)),
                SizedBox(width: 6),
                Text('Create New Task', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFF15283B))),
              ],
            ),
            const SizedBox(height: 4),
            const Text(
              'Assign a new task to your team member',
              style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD8DDE6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Task Details', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF15283B))),
                  const SizedBox(height: 14),
                  const Text('Task Title *', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Task title is required';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Enter a clear, descriptive task title',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Description *', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 4,
                    maxLines: 4,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Description is required';
                      }
                      return null;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Provide detailed instructions and context for this task...',
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text('Priority Level *', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _priority,
                    items: const [
                      DropdownMenuItem(value: 'High Priority', child: Text('High Priority')),
                      DropdownMenuItem(value: 'Medium Priority', child: Text('Medium Priority')),
                      DropdownMenuItem(value: 'Low Priority', child: Text('Low Priority')),
                    ],
                    onChanged: (value) => setState(() => _priority = value!),
                  ),
                  const SizedBox(height: 10),
                  const Text('Due Date *', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  TextFormField(
                    readOnly: true,
                    controller: _dueDateController,
                    decoration: const InputDecoration(
                      hintText: 'Select due date',
                      prefixIcon: Icon(Icons.calendar_today_outlined),
                    ),
                    onTap: _pickDueDate,
                  ),
                  const SizedBox(height: 10),
                  const Text('Assign To', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 6),
                  DropdownButtonFormField<String>(
                    initialValue: _assignee,
                    items: const [
                      DropdownMenuItem(value: 'Sarah Johnson', child: Text('Sarah Johnson')),
                      DropdownMenuItem(value: 'Michael Chen', child: Text('Michael Chen')),
                      DropdownMenuItem(value: 'Emily Rodriguez', child: Text('Emily Rodriguez')),
                      DropdownMenuItem(value: 'David Kim', child: Text('David Kim')),
                    ],
                    onChanged: (value) => setState(() => _assignee = value!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFD8DDE6)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Expanded(
                        child: Text('Micro Tasks\n(Optional)', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700, color: Color(0xFF15283B))),
                      ),
                      OutlinedButton.icon(onPressed: () {}, icon: const Icon(Icons.auto_awesome_outlined), label: const Text('AI Generate')),
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Break down the task into smaller, manageable steps to help your team member succeed.',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 10),
                  ...List.generate(_microSteps.length, (i) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(color: const Color(0xFFE8F3EE), borderRadius: BorderRadius.circular(8)),
                            alignment: Alignment.center,
                            child: Text('${i + 1}', style: const TextStyle(fontSize: 18, color: Color(0xFF1F2937))),
                          ),
                          const SizedBox(width: 8),
                          Expanded(child: TextField(controller: _microSteps[i], decoration: InputDecoration(hintText: 'Step ${i + 1}...'))),
                        ],
                      ),
                    );
                  }),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () =>
                          setState(() => _microSteps.add(TextEditingController())),
                      child: const Text('+ Add Step'),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFECF3FF),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: const Color(0xFFBCD5FF)),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Color(0xFF2F80ED)),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Accessibility Features Enabled\nThis task will be available with AI simplification, focus mode, and modal proof submission options.',
                      style: TextStyle(fontSize: 14, color: Color(0xFF234A99)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isSubmitting ? null : _handleCreateTask,
                    style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF2F80ED)),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'Create Task',
                            style: TextStyle(color: Colors.white),
                          ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
