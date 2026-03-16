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
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? 'Chưa có tên',
      description: json['description'] as String?,
      level: json['level'] as String?,
      estimatedDuration: (json['estimated_duration'] as num?)?.toInt(),
      thumbnailUrl: json['thumbnail_url'] as String?,
      days: (() {
        final v = json['days'];
        if (v == null) return null;
        if (v is int) return v;
        if (v is String) {
          final m = RegExp(r'\d+').firstMatch(v);
          if (m != null) return int.tryParse(m.group(0)!);
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
}
