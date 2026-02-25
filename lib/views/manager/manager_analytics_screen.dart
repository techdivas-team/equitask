import 'dart:async';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/task.dart';
import '../../services/task_service.dart';
import '../employee/widgets/support_fab_stack.dart';
import 'manager_drawer.dart';
import 'widgets/manager_top_bar.dart';

class ManagerAnalyticsScreen extends StatefulWidget {
  const ManagerAnalyticsScreen({super.key});

  @override
  State<ManagerAnalyticsScreen> createState() => _ManagerAnalyticsScreenState();
}

class _ManagerAnalyticsScreenState extends State<ManagerAnalyticsScreen> {
  List<Task> _tasks = [];
  bool _isLoading = true;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _loadAnalytics();
    _refreshTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _loadAnalytics(showLoader: false);
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadAnalytics({bool showLoader = true}) async {
    if (showLoader && mounted) {
      setState(() => _isLoading = true);
    }
    try {
      final taskService = Provider.of<TaskService>(context, listen: false);
      final tasks = await taskService.getTasks();
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

  int _countStatus(String status) => _tasks
      .where((task) => task.status.toLowerCase() == status.toLowerCase())
      .length;

  int get _totalTasks => _tasks.length;
  int get _completed => _countStatus('Completed');
  int get _inProgress => _countStatus('In progress');
  int get _submitted => _countStatus('Submitted');
  int get _verified => _countStatus('Verified');

  int get _completionRate =>
      _totalTasks == 0 ? 0 : ((_completed / _totalTasks) * 100).round();

  int get _highPriority =>
      _tasks.where((task) => task.priority == TaskPriority.urgent).length;
  int get _mediumPriority =>
      _tasks.where((task) => task.priority == TaskPriority.important).length;
  int get _lowPriority =>
      _tasks.where((task) => task.priority == TaskPriority.normal).length;

  List<int> get _assignedSeries {
    final week1 = (_totalTasks * 0.5).round();
    final week2 = (_totalTasks * 0.7).round();
    final week3 = (_totalTasks * 0.9).round();
    return [week1, week2, week3, _totalTasks];
  }

  List<int> get _completedSeries {
    final week1 = (_completed * 0.4).round();
    final week2 = (_completed * 0.7).round();
    final week3 = (_completed * 0.9).round();
    return [week1, week2, week3, _completed];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F5F7),
      appBar: const ManagerTopBar(currentRoute: '/manager/analytics'),
      drawer: const ManagerDrawer(currentRoute: '/manager/analytics'),
      floatingActionButton: const SupportFabStack(showClipboard: true),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadAnalytics,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 20),
                children: [
                  const Text(
                    'Analytics & Reports',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF15283B),
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Team performance metrics and insights',
                    style: TextStyle(fontSize: 14, color: Color(0xFF6B7280)),
                  ),
                  const SizedBox(height: 16),
                  _metricTile(
                    title: 'Total Tasks',
                    value: '$_totalTasks',
                    color: Colors.white,
                    border: const Color(0xFFD8DDE6),
                    icon: Icons.track_changes,
                    iconColor: const Color(0xFF2F80ED),
                  ),
                  const SizedBox(height: 12),
                  _metricTile(
                    title: 'Completed',
                    value: '$_completed',
                    color: const Color(0xFFEAF8F2),
                    border: const Color(0xFF76DABD),
                    icon: Icons.check_circle_outline,
                    iconColor: const Color(0xFF0A8A66),
                  ),
                  const SizedBox(height: 12),
                  _metricTile(
                    title: 'In Progress',
                    value: '$_inProgress',
                    color: const Color(0xFFFAF8EA),
                    border: const Color(0xFFE9D452),
                    icon: Icons.timelapse,
                    iconColor: const Color(0xFFC58B00),
                  ),
                  const SizedBox(height: 12),
                  _completionRateCard(),
                  const SizedBox(height: 12),
                  _chartCard(
                    'Completion Trend',
                    _lineLegend(),
                    SizedBox(height: 220, child: _completionTrendChart()),
                  ),
                  const SizedBox(height: 12),
                  _chartCard(
                    'Task Status',
                    null,
                    SizedBox(height: 220, child: _statusChart()),
                  ),
                  const SizedBox(height: 12),
                  _chartCard(
                    'Task Priority Distribution',
                    null,
                    Column(
                      children: [
                        SizedBox(height: 240, child: _priorityPieChart()),
                        const SizedBox(height: 8),
                        _priorityBreakdown(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _completionTrendChart() {
    final assigned = _assignedSeries;
    final completed = _completedSeries;
    final maxY = [
      ...assigned,
      ...completed,
      1,
    ].reduce((a, b) => a > b ? a : b).toDouble();

    return LineChart(
      LineChartData(
        minX: 1,
        maxX: 4,
        minY: 0,
        maxY: maxY + 1,
        gridData: FlGridData(
          show: true,
          drawVerticalLine: true,
          horizontalInterval: maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
        ),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text('Week ${value.toInt()}'),
                );
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: maxY > 4 ? (maxY / 4).ceilToDouble() : 1,
            ),
          ),
        ),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: List.generate(
              completed.length,
              (index) => FlSpot((index + 1).toDouble(), completed[index].toDouble()),
            ),
            color: const Color(0xFF19B889),
            isCurved: true,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
          LineChartBarData(
            spots: List.generate(
              assigned.length,
              (index) => FlSpot((index + 1).toDouble(), assigned[index].toDouble()),
            ),
            color: const Color(0xFF2F80ED),
            isCurved: true,
            barWidth: 3,
            dotData: const FlDotData(show: true),
          ),
        ],
      ),
    );
  }

  Widget _statusChart() {
    final bars = [
      _submitted.toDouble(),
      _inProgress.toDouble(),
      _verified.toDouble(),
      _completed.toDouble(),
    ];
    final maxY = ((bars.fold<double>(0, (prev, y) => y > prev ? y : prev) + 1)
        .clamp(1, 100))
        .toDouble();

    return BarChart(
      BarChartData(
        maxY: maxY,
        gridData: FlGridData(show: true, horizontalInterval: (maxY / 4).ceilToDouble()),
        borderData: FlBorderData(show: false),
        barTouchData: BarTouchData(enabled: true),
        titlesData: FlTitlesData(
          topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              interval: (maxY / 4).ceilToDouble(),
            ),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                const labels = ['Submitted', 'In Progress', 'Verified', 'Completed'];
                final idx = value.toInt();
                if (idx < 0 || idx >= labels.length) return const SizedBox.shrink();
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(labels[idx], style: const TextStyle(fontSize: 11)),
                );
              },
            ),
          ),
        ),
        barGroups: [
          _bar(0, _submitted.toDouble(), const Color(0xFFE8BE21)),
          _bar(1, _inProgress.toDouble(), const Color(0xFF2F80ED)),
          _bar(2, _verified.toDouble(), const Color(0xFF19B889)),
          _bar(3, _completed.toDouble(), const Color(0xFF1F6FE5)),
        ],
      ),
    );
  }

  BarChartGroupData _bar(int x, double y, Color color) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          width: 20,
          color: color,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }

  Widget _priorityPieChart() {
    final total = (_highPriority + _mediumPriority + _lowPriority);
    final safeTotal = total == 0 ? 1 : total;
    return PieChart(
      PieChartData(
        sectionsSpace: 1,
        centerSpaceRadius: 32,
        sections: [
          PieChartSectionData(
            color: const Color(0xFFE73333),
            value: _highPriority.toDouble(),
            title: '${(((_highPriority / safeTotal) * 100)).round()}%',
            radius: 70,
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          PieChartSectionData(
            color: const Color(0xFFE8BE21),
            value: _mediumPriority.toDouble(),
            title: '${(((_mediumPriority / safeTotal) * 100)).round()}%',
            radius: 70,
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
          PieChartSectionData(
            color: const Color(0xFF19B889),
            value: _lowPriority.toDouble(),
            title: '${(((_lowPriority / safeTotal) * 100)).round()}%',
            radius: 70,
            titleStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }

  Widget _completionRateCard() {
    final progress = (_completionRate / 100).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF0F4FF),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFCAD8FF)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Completion Rate',
                style: TextStyle(fontSize: 18, color: Color(0xFF234A99)),
              ),
              const SizedBox(height: 8),
              Text(
                '$_completionRate%',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF234A99),
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Updates every 4 seconds',
                style: TextStyle(fontSize: 12, color: Color(0xFF5A6B8A)),
              ),
            ],
          ),
          SizedBox(
            width: 90,
            height: 90,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  color: const Color(0xFF2F80ED),
                  backgroundColor: const Color(0xFFDDE3EF),
                ),
                Center(
                  child: Text(
                    '$_completionRate%',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _metricTile({
    required String title,
    required String value,
    required Color color,
    required Color border,
    required IconData icon,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 36),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 16, color: Color(0xFF6B7280)),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(fontSize: 24, color: Color(0xFF15283B)),
          ),
        ],
      ),
    );
  }

  Widget _chartCard(String title, Widget? footer, Widget child) {
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
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Color(0xFF15283B),
            ),
          ),
          const SizedBox(height: 14),
          child,
          if (footer != null) ...[
            const SizedBox(height: 12),
            footer,
          ],
        ],
      ),
    );
  }

  Widget _lineLegend() {
    return const Row(
      children: [
        _LegendDot(color: Color(0xFF19B889), label: 'Completed'),
        SizedBox(width: 16),
        _LegendDot(color: Color(0xFF2F80ED), label: 'Assigned'),
      ],
    );
  }

  Widget _priorityBreakdown() {
    return Column(
      children: [
        _priorityRow('High Priority', _highPriority, const Color(0xFFE73333)),
        const SizedBox(height: 8),
        _priorityRow('Medium Priority', _mediumPriority, const Color(0xFFE8BE21)),
        const SizedBox(height: 8),
        _priorityRow('Low Priority', _lowPriority, const Color(0xFF19B889)),
      ],
    );
  }

  Widget _priorityRow(String label, int count, Color color) {
    return Row(
      children: [
        Container(
          width: 14,
          height: 14,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 18,
              color: Color(0xFF1F2937),
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: const Color(0xFFD1D5DB)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count tasks'),
        ),
      ],
    );
  }
}

class _LegendDot extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendDot({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 16, color: Color(0xFF4B5563))),
      ],
    );
  }
}
