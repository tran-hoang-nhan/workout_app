
// Tính BMI
 double calculateBMI(double weight, double height) {
  if (height <= 0) return 0;
  final heightMeters = height / 100;
  return weight / (heightMeters * heightMeters);
}

// Phân loại BMI
String getBMICategory(double bmi) {
  if (bmi < 18.5) return 'Thiếu cân';
  if (bmi < 25) return 'Bình thường';
  if (bmi < 30) return 'Thừa cân';
  return 'Béo phì';
}

// Tính BMR
int calculateBMR(double weight, double height, int age, String gender) {
  double bmr;
  if (gender.toLowerCase() == 'male' || gender.toLowerCase() == 'nam') {
    bmr = 10 * weight + 6.25 * height - 5 * age + 5;
  } else {
    bmr = 10 * weight + 6.25 * height - 5 * age - 161;
  }
  return bmr.toInt();
}

// Tính TDEE
int calculateTDEE(int bmr, String activityLevel) {
  double multiplier = 1.2;
  switch (activityLevel.toLowerCase()) {
    case 'sedentary':
    case 'it_van_dong':
      multiplier = 1.2;
      break;
    case 'lightly_active':
    case 'van_dong_nhe':
      multiplier = 1.375;
      break;
    case 'moderately_active':
    case 'van_dong_vua':
      multiplier = 1.55;
      break;
    case 'very_active':
    case 'van_dong_cao':
      multiplier = 1.725;
      break;
    case 'extra_active':
    case 'van_dong_rat_cao':
      multiplier = 1.9;
      break;
    default:
      multiplier = 1.2;
  }
  return (bmr * multiplier).toInt();
}

// Tính nhịp tim tối đa
int calculateMaxHeartRate(int age) => 220 - age;

// Vùng đốt mỡ
({int min, int max}) calculateFatBurnZone(int maxHR) =>
    (min: (maxHR * 0.6).toInt(), max: (maxHR * 0.7).toInt());

// Vùng cardio
({int min, int max}) calculateCardioZone(int maxHR) =>
    (min: (maxHR * 0.7).toInt(), max: (maxHR * 0.8).toInt());
