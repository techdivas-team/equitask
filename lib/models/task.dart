enum TaskPriority { urgent, important, normal }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime dueDate;
  final TaskPriority priority;
  final String status;
  final bool isActive;

  Task({
    required this.id,
    required this.title,
    required this.description,
    required this.dueDate,
    required this.priority,
    required this.status,
    required this.isActive,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final rawPriority = (json['priority'] ?? json['urgencyColor'] ?? 'normal')
        .toString();
    final rawDueDate = json['dueDate']?.toString();
    final rawStatus = (json['status'] ?? 'Pending').toString();

    return Task(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      dueDate: rawDueDate != null
          ? DateTime.tryParse(rawDueDate) ?? DateTime.now()
          : DateTime.now(),
      priority: _priorityFromString(rawPriority),
      status: _normalizeStatus(rawStatus),
      isActive: (json['isActive'] as bool?) ?? true,
    );
  }

  static TaskPriority _priorityFromString(String priority) {
    switch (priority.toLowerCase()) {
      case 'urgent':
      case 'red':
        return TaskPriority.urgent;
      case 'important':
      case 'yellow':
      case 'orange':
        return TaskPriority.important;
      case 'green':
      default:
        return TaskPriority.normal;
    }
  }

  static String _normalizeStatus(String status) {
    return status
        .replaceAll('_', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map(
          (word) =>
              '${word[0].toUpperCase()}${word.length > 1 ? word.substring(1).toLowerCase() : ''}',
        )
        .join(' ');
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'dueDate': dueDate.toIso8601String(),
      'priority': priority.toString().split('.').last,
      'status': status,
      'isActive': isActive,
    };
  }
}
