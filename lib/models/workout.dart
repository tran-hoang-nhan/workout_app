class Workout {
  final int id;
  final String title;
  final String? description;
  final String? level;
  final int? estimatedDuration;
  final String? thumbnailUrl;
  final int? days;

  Workout({
    required this.id,
    required this.title,
    this.description,
    this.level,
    this.estimatedDuration,
    this.thumbnailUrl,
    this.days,
  });

  factory Workout.fromJson(Map<String, dynamic> json) {
    return Workout(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      level: json['level'],
      estimatedDuration: json['estimated_duration'],
      thumbnailUrl: json['thumbnail_url'],
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
      'estimated_duration': estimatedDuration,
      'thumbnail_url': thumbnailUrl,
      'days': days,
    };
  }

  Workout copyWith({
    int? id,
    String? title,
    String? description,
    String? level,
    int? estimatedDuration,
    String? thumbnailUrl,
    int? days,
  }) {
    return Workout(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      level: level ?? this.level,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      thumbnailUrl: thumbnailUrl ?? this.thumbnailUrl,
      days: days ?? this.days,
    );
  }
}
