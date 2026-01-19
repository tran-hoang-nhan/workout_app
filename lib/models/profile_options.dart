enum Gender {
  male('male', 'Nam'),
  female('female', 'Nữ'),
  other('other', 'Khác'),
  unknown('', 'Chưa cập nhật');

  final String value;
  final String label;

  const Gender(this.value, this.label);

  static Gender fromValue(String? value) {
    if (value == null || value.isEmpty) return Gender.unknown;
    try {
      return Gender.values.firstWhere(
        (g) => g.value.toLowerCase() == value.toLowerCase(),
        orElse: () => Gender.unknown,
      );
    } catch (_) {
      return Gender.unknown;
    }
  }
}

enum UserGoal {
  lose('lose', 'Giảm cân'),
  loseWeight('lose_weight', 'Giảm cân'),
  maintain('maintain', 'Duy trì'),
  gain('gain', 'Tăng cân'),
  gainMuscle('gain_muscle', 'Tăng cân'),
  lifestyle('lifestyle', 'Sống khỏe'),
  unknown('', 'Chưa cập nhật');

  final String value;
  final String label;

  const UserGoal(this.value, this.label);

  static UserGoal fromValue(String? value) {
    if (value == null || value.isEmpty) return UserGoal.unknown;
    final normalized = value.toLowerCase();
    try {
      return UserGoal.values.firstWhere(
        (g) => g.value.toLowerCase() == normalized,
        orElse: () => UserGoal.unknown,
      );
    } catch (_) {
      return UserGoal.unknown;
    }
  }
}

enum ActivityLevel {
  sedentary('sedentary', 'Ít vận động'),
  lightlyActive('lightly_active', 'Vận động nhẹ'),
  moderatelyActive('moderately_active', 'Vận động trung bình'),
  veryActive('very_active', 'Vận động nhiều'),
  extremelyActive('extremely_active', 'Vận động cực nhiều'),
  unknown('', 'Chưa cập nhật');

  final String value;
  final String label;

  const ActivityLevel(this.value, this.label);

  static ActivityLevel fromValue(String? value) {
    if (value == null || value.isEmpty) return ActivityLevel.unknown;
    final normalized = value.toLowerCase();
    try {
      return ActivityLevel.values.firstWhere(
        (a) => a.value.toLowerCase() == normalized,
        orElse: () => ActivityLevel.unknown,
      );
    } catch (_) {
      return ActivityLevel.unknown;
    }
  }
}
