import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/task_service.dart';
import 'widgets/stats_card.dart';
import 'widgets/task_card.dart';
import 'employee_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  late final TaskService _taskService;
  Map<String, dynamic>? _stats;
  List? _recentTasks;
  bool _isLoading = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _taskService = Provider.of<TaskService>(context);
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      // Fetch dashboard stats and recent tasks
      final stats = await _taskService.getDashboardStats();
      final tasks = await _taskService.getTasks();
      setState(() {
        _stats = stats;
        _recentTasks = tasks.take(3).toList(); // show only first 3
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      // Show error dialog/snackbar
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dashboard'), centerTitle: false),
      drawer: EmployeeDrawer(),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Stats row 1
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            label: 'Total Tasks',
                            value: '${_stats?['totalTasks'] ?? 0}',
                            icon: Icons.assignment,
                            color: Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            label: 'In Progress',
                            value: '${_stats?['inProgress'] ?? 0}',
                            icon: Icons.hourglass_empty,
                            color: Colors.orange,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Stats row 2
                    Row(
                      children: [
                        Expanded(
                          child: StatsCard(
                            label: 'Completion',
                            value: '${_stats?['completion'] ?? 0}%',
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: StatsCard(
                            label: 'Active Tasks',
                            value: '${_stats?['activeTasks'] ?? 0}',
                            icon: Icons.play_arrow,
                            color: Colors.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'Your Tasks',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${_stats?['activeTasks'] ?? 0} Active',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                    const SizedBox(height: 16),
                    if (_recentTasks != null && _recentTasks!.isNotEmpty)
                      ..._recentTasks!.map(
                        (task) => TaskCard(
                          task: task,
                          onSimplify: () {
                            // TODO: implement AI simplify action
                          },
                          onFocusMode: () {
                            // TODO: implement focus mode
                          },
                          onSubmitProof: () {
                            // TODO: implement submit proof
                          },
                        ),
                      ),
                    const SizedBox(height: 16),
                    Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/tasks');
                        },
                        child: const Text('View All Tasks'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
