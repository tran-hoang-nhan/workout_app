class AppUser {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? gender;
  final DateTime? dateOfBirth;
  final double? weight;
  final double? height;
  final int? age;
  final String? goal;
  final DateTime createdAt;
  final DateTime? updatedAt;

  AppUser({
    required this.id,
    required this.email,
    this.fullName,
    this.avatarUrl,
    this.gender,
    this.dateOfBirth,
    this.weight,
    this.height,
    this.age,
    this.goal,
    required this.createdAt,
    this.updatedAt,
  });

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth'] as String) : null,
      weight: (json['weight'] as num?)?.toDouble(),
      height: (json['height'] as num?)?.toDouble(),
      age: json['age'] as int?,
      goal: json['goal'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'weight': weight,
      'height': height,
      'age': age,
      'goal': goal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}

class UserStats {
  final int totalWorkouts;
  final double totalHours;
  final int totalCalories;
  final int streak;
  final double? weight;
  final int? age;

  UserStats({
    required this.totalWorkouts,
    required this.totalHours,
    required this.totalCalories,
    required this.streak,
    this.weight,
    this.age,
  });

  factory UserStats.fromJson(Map<String, dynamic> json) {
    return UserStats(
      totalWorkouts: json['total_workouts'] ?? 0,
      totalHours: (json['total_hours'] as num?)?.toDouble() ?? 0,
      totalCalories: json['total_calories'] ?? 0,
      streak: json['streak'] ?? 0,
      weight: (json['weight'] as num?)?.toDouble(),
      age: json['age'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'total_workouts': totalWorkouts,
      'total_hours': totalHours,
      'total_calories': totalCalories,
      'streak': streak,
      'weight': weight,
      'age': age,
    };
  }
}
