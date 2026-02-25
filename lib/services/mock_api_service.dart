import 'api_services.dart';

class MockApiService implements ApiService {
  final List<Map<String, dynamic>> _tasks = [
    {
      'id': '1',
      'title': 'Complete Q1 Budget Report',
      'description':
          'Review and finalize the Q1 budget report with all department expenditures.',
      'dueDate': '2026-03-01T00:00:00Z',
      'priority': 'urgent',
      'status': 'Completed',
      'isActive': true,
    },
    {
      'id': '2',
      'title': 'Update Employee Training Materials',
      'description':
          'Revise employee onboarding training materials to include new safety protocols.',
      'dueDate': '2026-03-03T00:00:00Z',
      'priority': 'important',
      'status': 'In progress',
      'isActive': true,
    },
    {
      'id': '3',
      'title': 'Schedule Team Meeting',
      'description':
          'Coordinate with team members and lock a date for monthly sync.',
      'dueDate': '2026-03-05T00:00:00Z',
      'priority': 'normal',
      'status': 'Pending',
      'isActive': true,
    },
    {
      'id': '4',
      'title': 'Client Presentation Deck',
      'description': 'Finalize deck and submit for manager review.',
      'dueDate': '2026-03-02T00:00:00Z',
      'priority': 'urgent',
      'status': 'Verified',
      'isActive': true,
    },
    {
      'id': '5',
      'title': 'Accessibility Audit',
      'description': 'Run accessibility checks on onboarding screens.',
      'dueDate': '2026-03-07T00:00:00Z',
      'priority': 'important',
      'status': 'Submitted',
      'isActive': true,
    },
    {
      'id': '6',
      'title': 'Weekly Team Summary',
      'description': 'Compile weekly summary and send to leadership.',
      'dueDate': '2026-03-08T00:00:00Z',
      'priority': 'urgent',
      'status': 'Pending',
      'isActive': true,
    },
  ];

  int _taskCounter = 7;

  bool _isTasksEndpoint(String endpoint) =>
      endpoint == '/tasks' || endpoint == '/api/tasks';

  Map<String, dynamic> _taskStats() {
    final totalTasks = _tasks.length;
    final inProgress = _tasks
        .where((task) => task['status'].toString().toLowerCase() == 'in progress')
        .length;
    final completed = _tasks
        .where((task) => task['status'].toString().toLowerCase() == 'completed')
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

  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (endpoint == '/dashboard/stats') {
      return _taskStats();
    } else if (endpoint == '/notifications') {
      return {
        'notifications': [
          {
            'id': 'n1',
            'title': 'Task Due Today',
            'message': 'Complete Q1 Budget Report is due today at 5:00 PM.',
            'timestamp': '2026-02-25T09:30:00Z',
            'isRead': false,
          },
          {
            'id': 'n2',
            'title': 'Proof Submitted',
            'message': 'Your proof for Client Presentation Deck was received.',
            'timestamp': '2026-02-24T16:10:00Z',
            'isRead': true,
          },
          {
            'id': 'n3',
            'title': 'Focus Reminder',
            'message': 'You have 2 tasks in progress. Start Focus Mode now.',
            'timestamp': '2026-02-23T13:00:00Z',
            'isRead': false,
          },
        ],
      };
    } else if (endpoint == '/me' || endpoint == '/api/auth/me') {
      return {
        'success': true,
        'user': {
          'id': 'u1',
          'name': 'Nyara Employee',
          'email': 'nyara@example.com',
          'avatarUrl': null,
        },
      };
    } else if (endpoint == '/settings') {
      return {
        'pushNotifications': true,
        'focusReminders': true,
        'highContrast': false,
        'reduceMotion': false,
      };
    } else if (_isTasksEndpoint(endpoint)) {
      return {'success': true, 'tasks': _tasks};
    } else if (endpoint.startsWith('/tasks/') ||
        endpoint.startsWith('/api/tasks/')) {
      final id = endpoint.split('/').last;
      final task = _tasks.firstWhere(
        (item) => item['id'].toString() == id,
        orElse: () => <String, dynamic>{},
      );

      if (task.isEmpty) {
        throw Exception('Task not found');
      }
      return {'success': true, 'task': task};
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (endpoint == '/notifications/mark-all-read') {
      return {'success': true};
    }
    if (endpoint == '/auth/google' || endpoint == '/api/auth/google') {
      return {'success': true, 'token': 'mock_google_token'};
    }
    if (endpoint == '/login' ||
        endpoint == '/signup' ||
        endpoint == '/api/auth/login' ||
        endpoint == '/api/auth/register') {
      return {'success': true, 'token': 'mock_token'};
    }
    if (endpoint == '/forgot-password' ||
        endpoint == '/logout' ||
        endpoint == '/api/auth/forgot-password' ||
        endpoint == '/api/auth/logout') {
      return {'success': true};
    }
    if (_isTasksEndpoint(endpoint)) {
      final task = {
        'id': '${_taskCounter++}',
        'title': data['title'] ?? '',
        'description': data['description'] ?? '',
        'dueDate': data['dueDate'] ?? DateTime.now().toIso8601String(),
        'priority': data['priority'] ?? 'normal',
        'status': data['status'] ?? 'Pending',
        'isActive': true,
      };
      _tasks.insert(0, task);
      return {'success': true, 'message': 'Task created', 'task': task};
    }
    return {'success': true};
  }

  @override
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    await Future.delayed(const Duration(milliseconds: 300));

    if (endpoint == '/settings') {
      return {'success': true, ...data};
    }
    if (endpoint.startsWith('/tasks/') || endpoint.startsWith('/api/tasks/')) {
      final id = endpoint.split('/').last;
      final index = _tasks.indexWhere((item) => item['id'].toString() == id);
      if (index == -1) {
        throw Exception('Task not found');
      }
      _tasks[index] = {..._tasks[index], ...data};
      return {'success': true, 'task': _tasks[index]};
    }
    return {'success': true};
  }

  @override
  Future<void> delete(String endpoint) async {}
}
