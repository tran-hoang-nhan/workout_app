class SignInParams {
  final String email;
  final String password;

  SignInParams({
    required this.email,
    required this.password,
  });

  factory SignInParams.fromJson(Map<String, dynamic> json) {
    return SignInParams(
      email: json['email'] as String,
      password: json['password'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
    };
  }
}

class SignUpParams {
  final String email;
  final String password;
  final String fullName;
  final String? avatarUrl;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? goal;

  SignUpParams({
    required this.email,
    required this.password,
    required this.fullName,
    this.avatarUrl,
    this.gender,
    this.dateOfBirth,
    this.goal,
  });

  factory SignUpParams.fromJson(Map<String, dynamic> json) {
    return SignUpParams(
      email: json['email'] as String,
      password: json['password'] as String,
      fullName: json['full_name'] as String,
      avatarUrl: json['avatar_url'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth'] as String) : null,
      goal: json['goal'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'email': email,
      'password': password,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'goal': goal,
    };
  }
}

class UpdateProfileParams {
  final String userId;
  final String? fullName;
  final String? avatarUrl;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? goal;

  UpdateProfileParams({
    required this.userId,
    this.fullName,
    this.avatarUrl,
    this.gender,
    this.dateOfBirth,
    this.goal,
  });

  factory UpdateProfileParams.fromJson(Map<String, dynamic> json) {
    return UpdateProfileParams(
      userId: json['user_id'] as String,
      fullName: json['full_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      gender: json['gender'] as String?,
      dateOfBirth: json['date_of_birth'] != null ? DateTime.parse(json['date_of_birth'] as String) : null,
      goal: json['goal'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'avatar_url': avatarUrl,
      'gender': gender,
      'date_of_birth': dateOfBirth?.toIso8601String().split('T')[0],
      'goal': goal,
    };
  }
}

class AuthState {
  final dynamic session;
  final dynamic event;
  AuthState({required this.session, required this.event});
}
