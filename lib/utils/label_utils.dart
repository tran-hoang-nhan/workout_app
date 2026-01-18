/// Helper functions to convert database values to Vietnamese labels
class LabelUtils {
  /// Convert gender database value to Vietnamese label
  static String getGenderLabel(String? gender) {
    if (gender == null) return 'Chưa cập nhật';
    switch (gender.toLowerCase()) {
      case 'male':
        return 'Nam';
      case 'female':
        return 'Nữ';
      default:
        return gender;
    }
  }

  /// Convert goal database value to Vietnamese label
  static String getGoalLabel(String? goal) {
    if (goal == null) return 'Chưa cập nhật';
    switch (goal.toLowerCase()) {
      case 'lose':
      case 'lose_weight':
        return 'Giảm cân';
      case 'maintain':
        return 'Duy trì';
      case 'gain':
      case 'gain_muscle':
        return 'Tăng cân';
      default:
        return goal;
    }
  }

  /// Convert activity level database value to Vietnamese label
  static String getActivityLevelLabel(String? level) {
    if (level == null) return 'Chưa cập nhật';
    switch (level.toLowerCase()) {
      case 'sedentary':
        return 'Ít vận động';
      case 'lightly_active':
        return 'Vận động nhẹ';
      case 'moderately_active':
        return 'Vận động trung bình';
      case 'very_active':
        return 'Vận động nhiều';
      case 'extremely_active':
        return 'Vận động cực nhiều';
      default:
        return level;
    }
  }

  /// Convert diet type database value to Vietnamese label
  static String getDietTypeLabel(String? dietType) {
    if (dietType == null) return 'Chưa cập nhật';
    switch (dietType.toLowerCase()) {
      case 'normal':
        return 'Bình thường';
      case 'vegetarian':
        return 'Chay';
      case 'vegan':
        return 'Thuần chay';
      case 'keto':
        return 'Keto';
      case 'paleo':
        return 'Paleo';
      default:
        return dietType;
    }
  }

  static String getWorkoutLevelLabel(String? level) {
    if (level == null) return 'Chưa cập nhật';
    switch (level.toLowerCase()) {
      case 'beginner':
      case 'easy':
      case 'novice':
      case 'dễ':
        return 'Dễ';
      case 'intermediate':
      case 'medium':
      case 'trung bình':
        return 'Trung bình';
      case 'advanced':
      case 'hard':
      case 'expert':
      case 'khó':
      case 'nâng cao':
        return 'Nâng cao';
      default:
        return level;
    }
  }
}
