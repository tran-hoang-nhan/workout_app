class AppUser {
  final String id;
  final String email;
  final String? fullName;
  final String? avatarUrl;
  final String? gender;
  final DateTime? dateOfBirth;
  final double? height;
  final double? weight;
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
    this.height,
    this.weight,
    this.age,
    this.goal,
    required this.createdAt,
    this.updatedAt,
  }) : assert(id.isNotEmpty), assert(email.isNotEmpty);

  factory AppUser.fromJson(Map<String, dynamic> json) {
    double? height;
    final heightValue = json['height'];
    if (heightValue != null) {
      height = heightValue is int ? heightValue.toDouble() : heightValue as double;
    }

    return AppUser(
      id: json['id'] as String,
      email: json['email'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      height: height,
      weight: json['weight'] != null
          ? (json['weight'] is int ? (json['weight'] as int).toDouble() : json['weight'] as double)
          : null,
      age: json['age'] as int?,
      goal: json['goal'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
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
      'height': height,
      'weight': weight,
      'age': age,
      'goal': goal,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? fullName,
    String? avatarUrl,
    String? gender,
    DateTime? dateOfBirth,
    double? height,
    double? weight,
    int? age,
    String? goal,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      gender: gender ?? this.gender,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      height: height ?? this.height,
      weight: weight ?? this.weight,
      age: age ?? this.age,
      goal: goal ?? this.goal,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class UserStats {
  final int totalWorkouts;
  final double totalHours;
  final int totalCalories;
  final int streak;
  double? weight;
  double? height;
  int? age;

  UserStats({
    required this.totalWorkouts,
    required this.totalHours,
    required this.totalCalories,
    required this.streak,
    this.weight,
    this.height,
    this.age,
  });

  factory UserStats.empty() {
    return UserStats(
      totalWorkouts: 0,
      totalHours: 0,
      totalCalories: 0,
      streak: 0,
    );
  }
}

