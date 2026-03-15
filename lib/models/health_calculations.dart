class HealthCalculations {
  final double bmi;
  final String bmiCategory;
  final int bmr;
  final int tdee;
  final int maxHeartRate;
  final ({int min, int max}) zone1;
  final ({int min, int max}) zone2;
  final ({int min, int max}) zone3;
  final ({int min, int max}) zone4;
  final ({int min, int max}) zone5;

  HealthCalculations({
    required this.bmi,
    required this.bmiCategory,
    required this.bmr,
    required this.tdee,
    required this.maxHeartRate,
    required this.zone1,
    required this.zone2,
    required this.zone3,
    required this.zone4,
    required this.zone5,
  });
}
