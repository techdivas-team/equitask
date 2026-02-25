import 'dart:convert';
import 'api_services.dart';

class MockApiService implements ApiService {
  @override
  Future<Map<String, dynamic>> get(String endpoint) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 500));

    if (endpoint == '/dashboard/stats') {
      return {
        'totalTasks': 6,
        'inProgress': 2,
        'completion': 0,
        'activeTasks': 6,
      };
    } else if (endpoint == '/tasks') {
      return {
        'tasks': [
          {
            'id': '1',
            'title': 'Complete Q1 Budget Report',
            'description':
                'Review and finalize the Q1 budget report with all department expenditures. Include...',
            'dueDate': '2026-02-20T00:00:00Z',
            'priority': 'urgent',
            'status': 'Pending',
            'isActive': true,
          },
          {
            'id': '2',
            'title': 'Update Employee Training Materials',
            'description':
                'Revise the employee onboarding training materials to include the new safety...',
            'dueDate': '2026-02-25T00:00:00Z',
            'priority': 'important',
            'status': 'Pending',
            'isActive': true,
          },
          {
            'id': '3',
            'title': 'Schedule Team Meeting',
            'description':
                'Coordinate with all team members to schedule the monthly sync meeting. Find...',
            'dueDate': '2026-02-22T00:00:00Z',
            'priority': 'normal',
            'status': 'Pending',
            'isActive': true,
          },
        ],
      };
    }
    return {};
  }

  @override
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    return {'success': true};
  }

  @override
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    return {'success': true};
  }

  @override
  Future<void> delete(String endpoint) async {}
}
