class Goal {
  final int id;
  final int userId;
  final String title;
  final String? description;
  final String type; // 'habit' or 'goal'
  final String category;
  final int targetValue;
  final int currentProgress;
  final String? deadline;
  final bool isCompleted;
  final String? lastLoggedDate;
  final String createdAt;
  final String updatedAt;
  

  Goal({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.type,
    required this.category,
    required this.targetValue,
    required this.currentProgress,
    this.deadline,
    required this.isCompleted,
    this.lastLoggedDate,   
    required this.createdAt,
    required this.updatedAt,
  });

  factory Goal.fromJson(Map<String, dynamic> json) {
    return Goal(
      id: json['id'],
      userId: json['user_id'],
      title: json['title'],
      description: json['description'],
      type: json['type'] ?? 'goal',
      category: json['category'] ?? 'Other',
      targetValue: (json['target_value'] as int?) ?? 0,
      currentProgress: (json['current_progress'] as int?) ?? 0,
      deadline: json['deadline'],
      isCompleted: json['is_completed'] == true || json['is_completed'] == 1,
      lastLoggedDate: json['last_logged_date'],
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'description': description,
      'type': type,
      'category': category,
      'target_value': targetValue,
      'current_progress': currentProgress,
      'deadline': deadline,
      'is_completed': isCompleted,
      'last_logged_date': lastLoggedDate,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
