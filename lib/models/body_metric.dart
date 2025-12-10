class BodyMetric {
  final int id;
  final String userId;
  final double weight;
  final double? bmi;
  final DateTime recordedAt;

  BodyMetric({
    required this.id,
    required this.userId,
    required this.weight,
    this.bmi,
    required this.recordedAt,
  });

  factory BodyMetric.fromJson(Map<String, dynamic> json) {
    return BodyMetric(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? '',
      weight: (json['weight'] ?? 0).toDouble(),
      bmi: json['bmi']?.toDouble(),
      recordedAt: json['recorded_at'] != null
          ? DateTime.parse(json['recorded_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'weight': weight,
      'bmi': bmi,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }

  BodyMetric copyWith({
    int? id,
    String? userId,
    double? weight,
    double? bmi,
    DateTime? recordedAt,
  }) {
    return BodyMetric(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      weight: weight ?? this.weight,
      bmi: bmi ?? this.bmi,
      recordedAt: recordedAt ?? this.recordedAt,
    );
  }
}
