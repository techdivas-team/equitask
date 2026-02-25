import '../models/task.dart';
import 'api_services.dart';

class TaskService {
  final ApiService _apiService;

  TaskService(this._apiService);

  Future<List<Task>> getTasks() async {
    final response = await _apiService.get('/tasks');
    final List<dynamic> tasksJson = response['tasks'];
    return tasksJson.map((json) => Task.fromJson(json)).toList();
  }

  Future<Task> getTask(String id) async {
    final response = await _apiService.get('/tasks/$id');
    return Task.fromJson(response);
  }

  Future<void> updateTaskStatus(String id, String status) async {
    await _apiService.put('/tasks/$id', {'status': status});
  }

  // New method for dashboard stats
  Future<Map<String, dynamic>> getDashboardStats() async {
    return await _apiService.get('/dashboard/stats');
  }
}
