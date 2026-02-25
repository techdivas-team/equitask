import '../models/task.dart';
import 'api_services.dart';

class TaskService {
  final ApiService _apiService;

  TaskService(this._apiService);

  Future<List<Task>> getTasks() async {
    final response = await _apiService.get('/api/tasks');
    final List<dynamic> tasksJson = response['tasks'] as List<dynamic>? ?? [];
    return tasksJson.map((json) => Task.fromJson(json)).toList();
  }

  Future<Task> getTask(String id) async {
    final response = await _apiService.get('/api/tasks/$id');
    final taskJson = response['task'] as Map<String, dynamic>? ?? response;
    return Task.fromJson(taskJson);
  }

  Future<void> updateTaskStatus(String id, String status) async {
    await _apiService.put('/api/tasks/$id', {'status': status});
  }

  Future<Task> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    String status = 'Pending',
  }) async {
    final response = await _apiService.post('/api/tasks', {
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.name,
      'status': status,
    });
    final taskJson = response['task'] as Map<String, dynamic>? ?? response;
    return Task.fromJson(taskJson);
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final tasks = await getTasks();
    final totalTasks = tasks.length;
    final inProgress = tasks
        .where((task) => task.status.toLowerCase() == 'in progress')
        .length;
    final completed = tasks
        .where((task) => task.status.toLowerCase() == 'completed')
        .length;
    final completion = totalTasks == 0
        ? 0
        : ((completed / totalTasks) * 100).round();

    return {
      'totalTasks': totalTasks,
      'inProgress': inProgress,
      'completion': completion,
      'activeTasks': totalTasks - completed,
    };
  }
}
