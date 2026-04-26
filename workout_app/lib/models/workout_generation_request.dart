class WorkoutGenerationRequest {
  final double weight;
  final double height;
  final String goal;
  final String? requirement;
  final String dietType;
  final List<String> medicalConditions;

  WorkoutGenerationRequest({
    required this.weight,
    required this.height,
    required this.goal,
    required this.dietType,
    required this.medicalConditions,
    this.requirement,
  });

  Map<String, dynamic> toJson() => {
    'weight': weight,
    'height': height,
    'goal': goal,
    'requirement': requirement,
    'diet_type': dietType,
    'medical_conditions': medicalConditions,
  };
}
