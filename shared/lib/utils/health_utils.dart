
class HealthUtils {
  static double calculateBMI(double weight, double height) {
    if (height <= 0) return 0;
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  static String getBMICategory(double bmi) {
    if (bmi < 18.5) return 'Thiếu cân';
    if (bmi < 25) return 'Bình thường';
    if (bmi < 30) return 'Thừa cân';
    return 'Béo phì';
  }

  static int calculateBMR(double weight, double height, int age, String gender) {
    if (gender.toLowerCase() == 'male') {
      return (10 * weight + 6.25 * height - 5 * age + 5).round();
    } else {
      return (10 * weight + 6.25 * height - 5 * age - 161).round();
    }
  }

  static int calculateTDEE(int bmr, String activityLevel) {
    double factor;
    switch (activityLevel.toLowerCase()) {
      case 'sedentary': factor = 1.2; break;
      case 'lightly_active': factor = 1.375; break;
      case 'moderately_active': factor = 1.55; break;
      case 'very_active': factor = 1.725; break;
      case 'extra_active': factor = 1.9; break;
      default: factor = 1.2;
    }
    return (bmr * factor).round();
  }

  static int calculateMaxHeartRate(int age) => 220 - age;

  static ({int min, int max}) calculateZone1(int maxHR) => (min: (maxHR * 0.5).round(), max: (maxHR * 0.6).round());
  static ({int min, int max}) calculateZone2(int maxHR) => (min: (maxHR * 0.6).round(), max: (maxHR * 0.7).round());
  static ({int min, int max}) calculateZone3(int maxHR) => (min: (maxHR * 0.7).round(), max: (maxHR * 0.8).round());
  static ({int min, int max}) calculateZone4(int maxHR) => (min: (maxHR * 0.8).round(), max: (maxHR * 0.9).round());
  static ({int min, int max}) calculateZone5(int maxHR) => (min: (maxHR * 0.9).round(), max: maxHR);
}
