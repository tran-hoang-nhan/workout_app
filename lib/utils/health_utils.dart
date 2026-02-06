double calculateBMI(double weight, double height) {
  if (height <= 0) return 0;
  final heightMeters = height / 100;
  return weight / (heightMeters * heightMeters);
}

String getBMICategory(double bmi) {
  if (bmi < 18.5) return 'Thiếu cân';
  if (bmi < 25) return 'Bình thường';
  if (bmi < 30) return 'Thừa cân';
  return 'Béo phì';
}

int calculateBMR(double weight, double height, int age, String gender) {
  double bmr;
  if (gender.toLowerCase() == 'male' || gender.toLowerCase() == 'nam') {
    bmr = 10 * weight + 6.25 * height - 5 * age + 5;
  } else {
    bmr = 10 * weight + 6.25 * height - 5 * age - 161;
  }
  return bmr.toInt();
}

int calculateTDEE(int bmr, String activityLevel) {
  final multiplier = switch (activityLevel.toLowerCase()) {
    'lightly_active' || 'van_dong_nhe' => 1.375,
    'moderately_active' || 'van_dong_vua' => 1.55,
    'very_active' || 'van_dong_cao' => 1.725,
    'extra_active' || 'van_dong_rat_cao' => 1.9,
    _ => 1.2,
  };
  return (bmr * multiplier).toInt();
}

int calculateMaxHeartRate(int age) => 220 - age;

({int min, int max}) calculateZone1(int maxHR) => (min: (maxHR * 0.5).toInt(), max: (maxHR * 0.6).toInt());
({int min, int max}) calculateZone2(int maxHR) => (min: (maxHR * 0.6).toInt(), max: (maxHR * 0.7).toInt());
({int min, int max}) calculateZone3(int maxHR) => (min: (maxHR * 0.7).toInt(), max: (maxHR * 0.8).toInt());
({int min, int max}) calculateZone4(int maxHR) => (min: (maxHR * 0.8).toInt(), max: (maxHR * 0.9).toInt());
({int min, int max}) calculateZone5(int maxHR) => (min: (maxHR * 0.9).toInt(), max: maxHR);
