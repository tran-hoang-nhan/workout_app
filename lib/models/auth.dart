// Dùng cho màn hình Đăng Nhập
class SignInParams {
  final String email;
  final String password;

  SignInParams({required this.email, required this.password});
}

// Dùng cho màn hình Đăng Ký (Chứa password và các thông tin profile ban đầu)
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
}

// Dùng cho màn hình Cập nhật hồ sơ (Tất cả đều là optional vì user có thể chỉ sửa 1 trường)
class UpdateProfileParams {
  final String userId;
  final String? fullName;
  final String? avatarUrl;
  final String? gender;
  final DateTime? dateOfBirth;
  final String? goal;
  final double? height;

  UpdateProfileParams({
    required this.userId,
    this.fullName,
    this.avatarUrl,
    this.gender,
    this.dateOfBirth,
    this.goal,
    this.height,
  });

  Map<String, dynamic> toUpdateMap() {
    final map = <String, dynamic>{
      'updated_at': DateTime.now().toIso8601String(),
    };
    if (fullName != null) {
      map['full_name'] = fullName;
    }
    if (avatarUrl != null) {
      map['avatar_url'] = avatarUrl;
    }
    if (gender != null) {
      map['gender'] = gender;
    }
    if (dateOfBirth != null) {
      map['date_of_birth'] = dateOfBirth!.toIso8601String().split('T')[0];
    }
    if (goal != null) {
      map['goal'] = goal;
    }
    return map;
  }
}
