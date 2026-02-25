import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/task_service.dart';
import 'widgets/stats_card.dart';
import 'widgets/task_card.dart';
import 'widgets/employee_top_bar.dart';
import 'widgets/support_fab_stack.dart';
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
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: const EmployeeTopBar(currentRoute: '/dashboard'),
      drawer: const EmployeeDrawer(currentRoute: '/dashboard'),
      floatingActionButton: const SupportFabStack(),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadData,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
                children: [
                  StatsCard(
                    label: 'Total Tasks',
                    value: '${_stats?['totalTasks'] ?? 0}',
                    icon: Icons.check,
                    backgroundColor: const Color(0xFFECF4F2),
                    borderColor: const Color(0xFFD9E8E2),
                    iconColor: const Color(0xFFD2E5FF),
                  ),
                  const SizedBox(height: 12),
                  StatsCard(
                    label: 'In Progress',
                    value: '${_stats?['inProgress'] ?? 0}',
                    icon: Icons.access_time,
                    backgroundColor: const Color(0xFFEEF3FF),
                    borderColor: const Color(0xFFD8E3FF),
                    iconColor: const Color(0xFFBFD8FF),
                  ),
                  const SizedBox(height: 12),
                  StatsCard(
                    label: 'Completion',
                    value: '${_stats?['completion'] ?? 0}%',
                    icon: Icons.circle_outlined,
                    backgroundColor: Colors.white,
                    borderColor: const Color(0xFFE5E7EB),
                    iconColor: const Color(0xFFD1D5DB),
                    circleText: '${_stats?['completion'] ?? 0}%',
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Your Tasks',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF15283B),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFEAF4F0),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${_stats?['activeTasks'] ?? 0} Active',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF2B3A42),
                          ),
                        ),
                      ),
                    ],
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
                ],
              ),
            ),
    );
  }
}
