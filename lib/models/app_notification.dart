class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime timestamp;
  final bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.timestamp,
    required this.isRead,
  });

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    final rawTimestamp =
        (json['timestamp'] ?? json['createdAt'] ?? DateTime.now().toIso8601String())
            .toString();
    return AppNotification(
      id: (json['id'] ?? json['_id'] ?? '').toString(),
      title: (json['title'] ?? 'Notification').toString(),
      message: (json['message'] ?? json['body'] ?? '').toString(),
      timestamp: DateTime.tryParse(rawTimestamp) ?? DateTime.now(),
      isRead: (json['isRead'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
    };
  }
}
