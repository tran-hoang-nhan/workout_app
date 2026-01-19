class DailySummary {
  final int? id;
  final String userId;
  final DateTime date;
  final int stepsCount;
  final double activeEnergyBurned;
  final int activeMinutes;
  final double distanceMeters;
  final int? avgHeartRate;
  final int? minHeartRate;
  final int? maxHeartRate;
  final int? restingHeartRate;
  final Map<String, dynamic> heartRateZones;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DailySummary({
    this.id,
    required this.userId,
    required this.date,
    this.stepsCount = 0,
    this.activeEnergyBurned = 0,
    this.activeMinutes = 0,
    this.distanceMeters = 0,
    this.avgHeartRate,
    this.minHeartRate,
    this.maxHeartRate,
    this.restingHeartRate,
    this.heartRateZones = const {},
    this.createdAt,
    this.updatedAt,
  });

  factory DailySummary.fromJson(Map<String, dynamic> json) {
    return DailySummary(
      id: json['id'] as int?,
      userId: json['user_id'] as String,
      date: DateTime.parse(json['date'] as String),
      stepsCount: json['steps_count'] as int? ?? 0,
      activeEnergyBurned: (json['active_energy_burned'] as num?)?.toDouble() ?? 0.0,
      activeMinutes: json['active_minutes'] as int? ?? 0,
      distanceMeters: (json['distance_meters'] as num?)?.toDouble() ?? 0.0,
      avgHeartRate: json['avg_heart_rate'] as int?,
      minHeartRate: json['min_heart_rate'] as int?,
      maxHeartRate: json['max_heart_rate'] as int?,
      restingHeartRate: json['resting_heart_rate'] as int?,
      heartRateZones: json['heart_rate_zones'] as Map<String, dynamic>? ?? {},
      createdAt: json['created_at'] != null ? DateTime.parse(json['created_at'] as String) : null,
      updatedAt: json['updated_at'] != null ? DateTime.parse(json['updated_at'] as String) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'user_id': userId,
      'date': date.toIso8601String().split('T')[0],
      'steps_count': stepsCount,
      'active_energy_burned': activeEnergyBurned,
      'active_minutes': activeMinutes,
      'distance_meters': distanceMeters,
      'avg_heart_rate': avgHeartRate,
      'min_heart_rate': minHeartRate,
      'max_heart_rate': maxHeartRate,
      'resting_heart_rate': restingHeartRate,
      'heart_rate_zones': heartRateZones,
    };
  }

  DailySummary copyWith({
    int? id,
    String? userId,
    DateTime? date,
    int? stepsCount,
    double? activeEnergyBurned,
    int? activeMinutes,
    double? distanceMeters,
    int? avgHeartRate,
    int? minHeartRate,
    int? maxHeartRate,
    int? restingHeartRate,
    Map<String, dynamic>? heartRateZones,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DailySummary(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      date: date ?? this.date,
      stepsCount: stepsCount ?? this.stepsCount,
      activeEnergyBurned: activeEnergyBurned ?? this.activeEnergyBurned,
      activeMinutes: activeMinutes ?? this.activeMinutes,
      distanceMeters: distanceMeters ?? this.distanceMeters,
      avgHeartRate: avgHeartRate ?? this.avgHeartRate,
      minHeartRate: minHeartRate ?? this.minHeartRate,
      maxHeartRate: maxHeartRate ?? this.maxHeartRate,
      restingHeartRate: restingHeartRate ?? this.restingHeartRate,
      heartRateZones: heartRateZones ?? this.heartRateZones,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
