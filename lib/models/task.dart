enum TaskPriority { urgent, important, normal }

class Task {
  final String id;
  final String title;
  final String description;
  final DateTime? dueDate;
  final TaskPriority priority;
  final String status;
  final bool isActive;
  final String? organizationId;
  final String? createdBy;
  final String? assignedTo;
  final List<SimplifiedStep>? simplifiedSteps;
  final Proof? proof;
  final ManagerReview? managerReview;

  Task({
    required this.id,
    required this.title,
    required this.description,
    this.dueDate,
    required this.priority,
    required this.status,
    required this.isActive,
    this.organizationId,
    this.createdBy,
    this.assignedTo,
    this.simplifiedSteps,
    this.proof,
    this.managerReview,
  });

  factory Task.fromJson(Map<String, dynamic> json) {
    final rawPriority = (json['priority'] ?? json['urgencyColor'] ?? 'normal')
        .toString();
    final rawDueDate = json['dueDate']?.toString();
    final rawStatus = (json['status'] ?? 'not_started').toString();

    return Task(
      id: (json['_id'] ?? json['id'] ?? '').toString(),
      title: (json['title'] ?? '').toString(),
      description: (json['description'] ?? '').toString(),
      dueDate: rawDueDate != null ? DateTime.tryParse(rawDueDate) : null,
      priority: _priorityFromString(rawPriority),
      status: _normalizeStatus(rawStatus),
      isActive: (json['isActive'] as bool?) ?? true,
      organizationId: json['organizationId']?.toString(),
      createdBy: json['createdBy']?.toString(),
      assignedTo: json['assignedTo']?.toString(),
      simplifiedSteps: json['simplifiedSteps'] != null
          ? (json['simplifiedSteps'] as List)
                .map((s) => SimplifiedStep.fromJson(s))
                .toList()
          : null,
      proof: json['proof'] != null ? Proof.fromJson(json['proof']) : null,
      managerReview: json['managerReview'] != null
          ? ManagerReview.fromJson(json['managerReview'])
          : null,
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
      if (dueDate != null) 'dueDate': dueDate!.toIso8601String(),
      'priority': priority.toString().split('.').last,
      'urgencyColor': priority == TaskPriority.urgent
          ? 'red'
          : priority == TaskPriority.important
          ? 'yellow'
          : 'green',
      'status': status.toLowerCase().replaceAll(' ', '_'),
      'isActive': isActive,
      if (organizationId != null) 'organizationId': organizationId,
      if (createdBy != null) 'createdBy': createdBy,
      if (assignedTo != null) 'assignedTo': assignedTo,
      if (simplifiedSteps != null)
        'simplifiedSteps': simplifiedSteps!.map((s) => s.toJson()).toList(),
    };
  }
}

class SimplifiedStep {
  final int stepNumber;
  final String stepDescription;
  final bool isCompleted;

  SimplifiedStep({
    required this.stepNumber,
    required this.stepDescription,
    required this.isCompleted,
  });

  factory SimplifiedStep.fromJson(Map<String, dynamic> json) {
    return SimplifiedStep(
      stepNumber: (json['stepNumber'] ?? 0) as int,
      stepDescription: (json['stepDescription'] ?? '').toString(),
      isCompleted: (json['isCompleted'] as bool?) ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'stepNumber': stepNumber,
      'stepDescription': stepDescription,
      'isCompleted': isCompleted,
    };
  }
}

class Proof {
  final String? proofType;
  final String? text;
  final String? fileUrl;
  final String? fileName;
  final String? mimeType;
  final int? fileSize;
  final DateTime? submittedAt;
  final String? submittedBy;

  Proof({
    this.proofType,
    this.text,
    this.fileUrl,
    this.fileName,
    this.mimeType,
    this.fileSize,
    this.submittedAt,
    this.submittedBy,
  });

  factory Proof.fromJson(Map<String, dynamic> json) {
    final rawSubmittedAt = json['submittedAt']?.toString();
    return Proof(
      proofType: json['proofType']?.toString(),
      text: json['text']?.toString(),
      fileUrl: json['fileUrl']?.toString(),
      fileName: json['fileName']?.toString(),
      mimeType: json['mimeType']?.toString(),
      fileSize: json['fileSize'] as int?,
      submittedAt: rawSubmittedAt != null
          ? DateTime.tryParse(rawSubmittedAt)
          : null,
      submittedBy: json['submittedBy']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (proofType != null) 'proofType': proofType,
      if (text != null) 'text': text,
      if (fileUrl != null) 'fileUrl': fileUrl,
      if (fileName != null) 'fileName': fileName,
      if (mimeType != null) 'mimeType': mimeType,
      if (fileSize != null) 'fileSize': fileSize,
      if (submittedAt != null) 'submittedAt': submittedAt!.toIso8601String(),
      if (submittedBy != null) 'submittedBy': submittedBy,
    };
  }
}

class ManagerReview {
  final String? reviewedBy;
  final DateTime? reviewedAt;
  final String? decision;
  final String? comment;

  ManagerReview({
    this.reviewedBy,
    this.reviewedAt,
    this.decision,
    this.comment,
  });

  factory ManagerReview.fromJson(Map<String, dynamic> json) {
    final rawReviewedAt = json['reviewedAt']?.toString();
    return ManagerReview(
      reviewedBy: json['reviewedBy']?.toString(),
      reviewedAt: rawReviewedAt != null
          ? DateTime.tryParse(rawReviewedAt)
          : null,
      decision: json['decision']?.toString(),
      comment: json['comment']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (reviewedBy != null) 'reviewedBy': reviewedBy,
      if (reviewedAt != null) 'reviewedAt': reviewedAt!.toIso8601String(),
      if (decision != null) 'decision': decision,
      if (comment != null) 'comment': comment,
    };
  }
}
