class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;
  final String? type;
  final String? userId;
  final String? taskId;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
    this.type,
    this.userId,
    this.taskId,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawTimestamp =
        (json['timestamp'] ??
                json['createdAt'] ??
                DateTime.now().toIso8601String())
            .toString();
    return AppNotification(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? 'Notification').toString(),
      message: (json['message'] ?? json['body'] ?? '').toString(),
      timestamp: DateTime.tryParse(rawTimestamp) ?? DateTime.now(),
      isRead: (json['isRead'] as bool?) ?? false,
      type: json['type']?.toString(),
      userId: json['user']?.toString(),
      taskId: json['task']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      if (type != null) 'type': type,
      if (userId != null) 'user': userId,
      if (taskId != null) 'task': taskId,
    };
  }
}

enum NotificationType {
  proofSubmitted,
  proofApproved,
  proofRejected,
  taskDueSoon,
  taskDueNow,
}

extension NotificationTypeExtension on NotificationType {
  static NotificationType? fromString(String? value) {
    if (value == null) return null;
    switch (value) {
      case 'proof_submitted':
        return NotificationType.proofSubmitted;
      case 'proof_approved':
        return NotificationType.proofApproved;
      case 'proof_rejected':
        return NotificationType.proofRejected;
      case 'task_due_soon':
        return NotificationType.taskDueSoon;
      case 'task_due_now':
        return NotificationType.taskDueNow;
      default:
        return null;
    }
  }

  String get backendValue {
    switch (this) {
      case NotificationType.proofSubmitted:
        return 'proof_submitted';
      case NotificationType.proofApproved:
        return 'proof_approved';
      case NotificationType.proofRejected:
        return 'proof_rejected';
      case NotificationType.taskDueSoon:
        return 'task_due_soon';
      case NotificationType.taskDueNow:
        return 'task_due_now';
    }
  }
}
