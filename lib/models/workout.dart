class Workout {
  final int id;
  final String title;
  final String? description;
  final String? level;
  final String? category;
  final int? estimatedDuration;
  final String? thumbnailUrl;
  final bool isPremium;
  final int? days;

  Workout({
    required this.id,
    required this.title,
    this.description,
    this.level,
    this.category,
    this.estimatedDuration,
    this.thumbnailUrl,
    this.isPremium = false,
    this.days,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      level: json['level'],
      category: json['category'],
      estimatedDuration: json['estimated_duration'],
      thumbnailUrl: json['thumbnail_url'],
      isPremium: json['is_premium'] ?? false,
      days: (() {
        final v = json['days'];
        if (v == null) return null;
        if (v is int) return v;
        if (v is String) {
          final m = RegExp(r'\d+').firstMatch(v);
          if (m != null) {
            return int.tryParse(m.group(0)!);
          }
          return null;
        }
        return null;
      })(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'level': level,
      'category': category,
      'estimated_duration': estimatedDuration,
      'thumbnail_url': thumbnailUrl,
      'is_premium': isPremium,
      'days': days,
    };
  }

  Workout copyWith({
    int? id,
    String? title,
    String? description,
    String? level,
    String? category,
    int? estimatedDuration,
    String? thumbnailUrl,
    bool? isPremium,
    int? days,
  }) {
    return Workout(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      category: category ?? this.category,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      isPremium: isPremium ?? this.isPremium,
      days: days ?? this.days,
    );
  }
}
