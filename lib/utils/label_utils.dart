import '../models/profile_options.dart';

class LabelUtils {
  static String getGenderLabel(String? gender) => Gender.fromValue(gender).label;

  static String getGoalLabel(String? goal) => UserGoal.fromValue(goal).label;

  static String getActivityLevelLabel(String? level) => ActivityLevel.fromValue(level).label;

  static String getDietTypeLabel(String? dietType) =>
      switch (dietType?.toLowerCase()) {
        'normal' => 'Bình thường',
        'vegetarian' => 'Chay',
        'vegan' => 'Thuần chay',
        'keto' => 'Keto',
        'paleo' => 'Paleo',
        null => 'Chưa cập nhật',
        _ => dietType!,
      };

  static String getWorkoutLevelLabel(String? level) =>
      switch (level?.toLowerCase()) {
        'beginner' || 'easy' || 'novice' || 'dễ' => 'Dễ',
        'intermediate' || 'medium' || 'trung bình' => 'Trung bình',
        'advanced' || 'hard' || 'expert' || 'khó' || 'nâng cao' => 'Nâng cao',
        null => 'Chưa cập nhật',
        _ => level!,
      };
}
