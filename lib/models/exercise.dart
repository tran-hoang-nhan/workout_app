class Exercise {
  final int id;
  final String name;
  final String? description;
  final String? animationUrl;
  final String? thumbnailUrl;
  final String? muscleGroup;
  final String? difficulty;
  final double? caloriesPerMinute;

  Exercise({
    required this.id,
    required this.name,
    this.description,
    this.animationUrl,
    this.thumbnailUrl,
    this.muscleGroup,
    this.difficulty,
    this.caloriesPerMinute,
  });

  factory Exercise.fromJson(Map<String, dynamic> json) {
    return Exercise(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      animationUrl: json['animation_url'],
      thumbnailUrl: json['thumbnail_url'],
      muscleGroup: json['muscle_group'],
      difficulty: json['difficulty'],
      caloriesPerMinute: json['calories_per_minute']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'animation_url': animationUrl,
      'thumbnail_url': thumbnailUrl,
      'muscle_group': muscleGroup,
      'difficulty': difficulty,
      'calories_per_minute': caloriesPerMinute,
    };
  }

  Exercise copyWith({
    int? id,
    String? name,
    String? description,
    String? animationUrl,
    String? thumbnailUrl,
    String? muscleGroup,
    String? difficulty,
    double? caloriesPerMinute,
  }) {
    return Exercise(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      animationUrl: animationUrl ?? this.animationUrl,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      muscleGroup: muscleGroup ?? this.muscleGroup,
      difficulty: difficulty ?? this.difficulty,
      caloriesPerMinute: caloriesPerMinute ?? this.caloriesPerMinute,
    );
  }
}
