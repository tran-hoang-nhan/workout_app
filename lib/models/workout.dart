class Workout {
  final int id;
  final String title;
  final String? description;
  final String? level;
  final int? estimatedDuration;
  final String? thumbnailUrl;
  final bool isPremium;

  Workout({
    required this.id,
    required this.title,
    this.description,
    this.level,
    this.estimatedDuration,
    this.thumbnailUrl,
    this.isPremium = false,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      level: json['level'],
      estimatedDuration: json['estimated_duration'],
      thumbnailUrl: json['thumbnail_url'],
      isPremium: json['is_premium'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'estimated_duration': estimatedDuration,
      'thumbnail_url': thumbnailUrl,
      'is_premium': isPremium,
    };
  }

  Workout copyWith({
    int? id,
    String? title,
    String? description,
    String? level,
    int? estimatedDuration,
    String? thumbnailUrl,
    bool? isPremium,
  }) {
    return Workout(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
