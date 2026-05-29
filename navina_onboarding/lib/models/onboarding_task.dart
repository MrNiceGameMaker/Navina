class OnboardingTask {
  final String? id;
  final String employeeId;
  final String title;
  final String category;
  final bool isCompleted;
  final DateTime? scheduledAt;
  final String? assignedStaff;

  const OnboardingTask({
    this.id,
    required this.employeeId,
    required this.title,
    required this.category,
    required this.isCompleted,
    this.scheduledAt,
    this.assignedStaff,
  });

  factory OnboardingTask.fromJson(Map<String, dynamic> json) {
    final rawScheduledAt = json['scheduled_at'];
    DateTime? parsedScheduledAt;
    if (rawScheduledAt is String && rawScheduledAt.isNotEmpty) {
      parsedScheduledAt = DateTime.tryParse(rawScheduledAt);
    }

    return OnboardingTask(
      id: json['id'] as String?,
      employeeId: json['employee_id'] as String,
      title: json['title'] as String,
      category: json['category'] as String,
      isCompleted: json['is_completed'] as bool,
      scheduledAt: parsedScheduledAt,
      assignedStaff: json['assigned_staff'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'employee_id': employeeId,
      'title': title,
      'category': category,
      'is_completed': isCompleted,
      if (scheduledAt != null) 'scheduled_at': scheduledAt!.toIso8601String(),
      if (assignedStaff != null) 'assigned_staff': assignedStaff,
    };
  }

  OnboardingTask copyWith({
    bool? isCompleted,
    DateTime? scheduledAt,
    String? assignedStaff,
  }) {
    return OnboardingTask(
      id: id,
      employeeId: employeeId,
      title: title,
      category: category,
      isCompleted: isCompleted ?? this.isCompleted,
      scheduledAt: scheduledAt ?? this.scheduledAt,
      assignedStaff: assignedStaff ?? this.assignedStaff,
    );
  }
}
