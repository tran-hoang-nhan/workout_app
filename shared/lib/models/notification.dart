enum NotificationType {
  reminder,
  achievement,
  system,
  workout,
  water,
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final bool isRead;
  final NotificationType type;
  final Map<String, dynamic>? data;
  final DateTime? drankAt;

  String get icon => switch (type) {
    NotificationType.workout => 'fitness_center',
    NotificationType.water => 'water_drop',
    NotificationType.achievement => 'emoji_events',
    NotificationType.reminder => 'notifications_active',
    NotificationType.system => 'info',
  };

  String get color => switch (type) {
    NotificationType.workout => '0xFFFF7F00',
    NotificationType.water => '0xFF00BCD4',
    NotificationType.achievement => '0xFFFFD700',
    NotificationType.reminder => '0xFF4CAF50',
    NotificationType.system => '0xFF2196F3',
  };

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    this.isRead = false,
    required this.type,
    this.data,
    this.drankAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as String,
      title: json['title'] as String,
      message: (json['message'] ?? json['body']) as String,
      createdAt: DateTime.parse(json['created_at'] as String),
      isRead: json['is_read'] as bool? ?? false,
      type: NotificationType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => NotificationType.system,
      ),
      data: json['data'] as Map<String, dynamic>?,
      drankAt: json['drank_at'] != null ? DateTime.parse(json['drank_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'created_at': createdAt.toIso8601String(),
      'is_read': isRead,
      'type': type.name,
      'data': data,
      'drank_at': drankAt?.toIso8601String(),
    };
  }

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    bool? isRead,
    NotificationType? type,
    Map<String, dynamic>? data,
    DateTime? drankAt,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
      data: data ?? this.data,
      drankAt: drankAt ?? this.drankAt,
    );
  }
}
