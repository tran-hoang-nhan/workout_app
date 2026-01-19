class LabelUtils {
  static String getGenderLabel(String? gender) =>
      switch (gender?.toLowerCase()) {
        'male' => 'Nam',
        'female' => 'Nữ',
        null => 'Chưa cập nhật',
        _ => gender!,
      };

  static String getGoalLabel(String? goal) => switch (goal?.toLowerCase()) {
    'lose' || 'lose_weight' => 'Giảm cân',
    'maintain' => 'Duy trì',
    'gain' || 'gain_muscle' => 'Tăng cân',
    null => 'Chưa cập nhật',
    _ => goal!,
  };

  static String getActivityLevelLabel(String? level) =>
      switch (level?.toLowerCase()) {
        'sedentary' => 'Ít vận động',
        'lightly_active' => 'Vận động nhẹ',
        'moderately_active' => 'Vận động trung bình',
        'very_active' => 'Vận động nhiều',
        'extremely_active' => 'Vận động cực nhiều',
        null => 'Chưa cập nhật',
        _ => level!,
      };

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
