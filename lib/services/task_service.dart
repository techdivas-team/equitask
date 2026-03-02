import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../models/task.dart';
import 'api_services.dart';
import 'http_api_service.dart';
import 'package:http/http.dart' as http;

class TaskService {
  final ApiService _apiService;

  TaskService(this._apiService);

  Future<Map<String, dynamic>> _getWithFallback(List<String> endpoints) async {
    Exception? lastError;
    for (final endpoint in endpoints) {
      try {
        return await _apiService.get(endpoint);
      } on Exception catch (e) {
        lastError = e;
      }
    }
    throw Exception(lastError?.toString() ?? 'Request failed');
  }

  Future<Map<String, dynamic>> _postWithFallback(
    List<String> endpoints,
    Map<String, dynamic> body,
  ) async {
    Exception? lastError;
    for (final endpoint in endpoints) {
      try {
        return await _apiService.post(endpoint, body);
      } on Exception catch (e) {
        lastError = e;
      }
    }
    throw Exception(lastError?.toString() ?? 'Request failed');
  }

  Future<List<Task>> getTasks() async {
    final response = await _getWithFallback(['/api/tasks', '/tasks']);
    final List<dynamic> tasksJson = response['tasks'] as List<dynamic>? ?? [];
    return tasksJson.map((json) => Task.fromJson(json)).toList();
  }

  Future<Task> getTask(String id) async {
    final response = await _apiService.get('/api/tasks/$id');
    final taskJson = response['task'] as Map<String, dynamic>? ?? response;
    return Task.fromJson(taskJson);
  }

  Future<void> updateTaskStatus(String id, String status) async {
    // Convert display status to backend status format
    final backendStatus = _convertToBackendStatus(status);
    await _apiService.put('/api/tasks/$id', {'status': backendStatus});
  }

  String _convertToBackendStatus(String displayStatus) {
    // Convert display status like "In Progress" to "in_progress"
    return displayStatus.toLowerCase().replaceAll(' ', '_');
  }

  Future<void> deleteTask(String id) async {
    await _apiService.delete('/api/tasks/$id');
  }

  Future<Task> createTask({
    required String title,
    required String description,
    required DateTime dueDate,
    required TaskPriority priority,
    String status = 'not_started',
  }) async {
    final response = await _postWithFallback(
      ['/api/tasks', '/tasks'],
      {
        'title': title,
        'description': description,
        'dueDate': dueDate.toIso8601String(),
        'priority': priority.name,
        'urgencyColor': priority == TaskPriority.urgent
            ? 'red'
            : priority == TaskPriority.important
            ? 'yellow'
            : 'green',
        'status': status,
      },
    );
    final taskJson = response['task'] as Map<String, dynamic>? ?? response;
    return Task.fromJson(taskJson);
  }

  Future<Map<String, dynamic>> getDashboardStats() async {
    final tasks = await getTasks();
    final totalTasks = tasks.length;
    final inProgress = tasks.where((task) {
      final status = task.status.toLowerCase();
      return status == 'in progress' || status == 'in_progress';
    }).length;
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

  Future<String> simplifyTaskDescription({
    required String taskDescription,
    String level = 'simple',
  }) async {
    try {
      final response = await _postWithFallback(
        ['/api/ai/simplify-task', '/ai/simplify-task'],
        {'taskDescription': taskDescription, 'level': level},
      );

      final dynamic simplified =
          response['simplifiedTask'] ??
          response['simplifiedText'] ??
          response['summary'] ??
          response['result'] ??
          response['data'];

      if (simplified is String && simplified.trim().isNotEmpty) {
        return simplified.trim();
      }

      if (simplified is List) {
        final lines = simplified
            .map((e) => e.toString().trim())
            .where((e) => e.isNotEmpty)
            .toList();
        if (lines.isNotEmpty) {
          return lines.join('\n');
        }
      }
    } catch (e) {
      // Fallback: generate simple steps from description
      debugPrint('AI simplify failed, using fallback: $e');
    }

    // Fallback: generate simple steps from description
    final sentences = taskDescription
        .split(RegExp(r'[.!?]'))
        .where((s) => s.trim().length > 5)
        .take(5)
        .toList();

    if (sentences.isEmpty) {
      return '1. Break down the task into smaller steps\n2. Set a deadline\n3. Complete the first step\n4. Review your work\n5. Submit completed task';
    }

    final steps = <String>[];
    for (var i = 0; i < sentences.length; i++) {
      steps.add('${i + 1}. ${sentences[i].trim()}');
    }
    return steps.join('\n');
  }

  Future<void> submitProofFile({
    required String taskId,
    required String fileName,
    String? filePath,
    List<int>? fileBytes,
  }) async {
    if (taskId.trim().isEmpty) {
      throw Exception('Task id is required for proof upload');
    }
    if (filePath == null && fileBytes == null) {
      throw Exception('No file selected');
    }

    final endpoints = ['/api/proof/$taskId/file', '/proof/$taskId/file'];
    Exception? lastError;

    for (final endpoint in endpoints) {
      try {
        await _uploadProofToEndpoint(
          endpoint: endpoint,
          fileName: fileName,
          filePath: filePath,
          fileBytes: fileBytes,
        );
        return;
      } on Exception catch (e) {
        lastError = e;
      }
    }

    throw Exception(lastError?.toString() ?? 'Proof upload failed');
  }

  Future<void> _uploadProofToEndpoint({
    required String endpoint,
    required String fileName,
    String? filePath,
    List<int>? fileBytes,
  }) async {
    if (_apiService is! HttpApiService) {
      throw Exception('Proof upload requires HttpApiService');
    }

    final httpApi = _apiService;
    final request = http.MultipartRequest(
      'POST',
      Uri.parse('${httpApi.baseUrl}$endpoint'),
    );

    final token = httpApi.authToken;
    if (token != null && token.isNotEmpty) {
      request.headers['Authorization'] = 'Bearer $token';
    }

    if (filePath != null && filePath.isNotEmpty) {
      request.files.add(await http.MultipartFile.fromPath('file', filePath));
    } else if (fileBytes != null) {
      request.files.add(
        http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
      );
    }

    final streamed = await request.send();
    final response = await http.Response.fromStream(streamed);

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String message = 'HTTP error ${response.statusCode}';
      try {
        final body = jsonDecode(response.body);
        if (body is Map && body['message'] != null) {
          message = body['message'].toString();
        }
      } catch (_) {}
      throw Exception(message);
    }
  }

  Future<void> submitTextProof({
    required String taskId,
    required String proofText,
  }) async {
    if (taskId.trim().isEmpty) {
      throw Exception('Task id is required for proof submission');
    }
    if (proofText.trim().isEmpty) {
      throw Exception('Proof text cannot be empty');
    }

    final endpoints = ['/api/proof/$taskId/text', '/proof/$taskId/text'];
    Exception? lastError;

    for (final endpoint in endpoints) {
      try {
        await _apiService.post(endpoint, {'text': proofText});
        return;
      } on Exception catch (e) {
        lastError = e;
      }
    }

    throw Exception(lastError?.toString() ?? 'Text proof submission failed');
  }

  Future<void> submitReviewProof({
    required String taskId,
    required String reviewText,
    String? status,
  }) async {
    if (taskId.trim().isEmpty) {
      throw Exception('Task id is required for review submission');
    }
    if (reviewText.trim().isEmpty) {
      throw Exception('Review text cannot be empty');
    }

    final endpoints = ['/api/proof/$taskId/review', '/proof/$taskId/review'];
    Exception? lastError;

    for (final endpoint in endpoints) {
      try {
        await _apiService.post(endpoint, {
          'review': reviewText,
          if (status != null) 'status': status,
        });
        return;
      } on Exception catch (e) {
        lastError = e;
      }
    }

    throw Exception(lastError?.toString() ?? 'Review proof submission failed');
  }

  /// Mark a step as completed
  Future<void> completeStep(String taskId, int stepNumber) async {
    if (taskId.trim().isEmpty) {
      throw Exception('Task id is required');
    }

    final endpoints = [
      '/api/tasks/$taskId/steps/$stepNumber',
      '/tasks/$taskId/steps/$stepNumber',
    ];
    Exception? lastError;

    for (final endpoint in endpoints) {
      try {
        await _apiService.patch(endpoint, {'isCompleted': true});
        return;
      } on Exception catch (e) {
        lastError = e;
      }
    }

    throw Exception(lastError?.toString() ?? 'Failed to complete step');
  }

  /// Get pending proofs for manager review
  Future<List<Task>> fetchPendingProofs() async {
    final response = await _getWithFallback([
      '/api/proof/pending',
      '/proof/pending',
    ]);
    final List<dynamic> tasksJson =
        response['tasks'] as List<dynamic>? ??
        response['pendingProofs'] as List<dynamic>? ??
        [];
    return tasksJson.map((json) => Task.fromJson(json)).toList();
  }
}
