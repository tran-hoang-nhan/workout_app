import 'package:flutter/material.dart';

enum NotificationType {
  workout,
  reminder,
  achievement,
  system,
  water
}

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final DateTime createdAt;
  final NotificationType type;
  final bool isRead;
  final String? route;
  final Map<String, dynamic>? data;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    required this.createdAt,
    required this.type,
    this.isRead = false,
    this.route,
    this.data,
  });

  NotificationModel copyWith({
    String? id,
    String? title,
    String? message,
    DateTime? createdAt,
    NotificationType? type,
    bool? isRead,
    String? route,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      title: title ?? this.title,
      message: message ?? this.message,
      createdAt: createdAt ?? this.createdAt,
      type: type ?? this.type,
      isRead: isRead ?? this.isRead,
      route: route ?? this.route,
      data: data ?? this.data,
    );
  }

  IconData get icon {
    switch (type) {
      case NotificationType.workout:
        return Icons.fitness_center;
      case NotificationType.reminder:
        return Icons.notifications_active;
      case NotificationType.achievement:
        return Icons.emoji_events;
      case NotificationType.system:
        return Icons.info_outline;
      case NotificationType.water:
        return Icons.water_drop;
    }
  }

  Color get color {
    switch (type) {
      case NotificationType.workout:
        return Colors.blue;
      case NotificationType.reminder:
        return Colors.orange;
      case NotificationType.achievement:
        return Colors.amber;
      case NotificationType.system:
        return Colors.grey;
      case NotificationType.water:
        return Colors.cyan;
    }
  }
}
