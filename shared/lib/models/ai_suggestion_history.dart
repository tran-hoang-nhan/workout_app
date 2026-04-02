import 'workout_plan.dart';

/// Represents a past AI workout suggestion history item.
class AISuggestionHistory {
  final int id;
  final DateTime recordedAt;
  final String? userPrompt;
  final WorkoutPlan? plan;
  final Map<String, dynamic>? healthContext;

  AISuggestionHistory({
    required this.id,
    required this.recordedAt,
    this.userPrompt,
    this.plan,
    this.healthContext,
  });

  factory AISuggestionHistory.fromJson(Map<String, dynamic> json) {
    return AISuggestionHistory(
      id: json['id'] as int,
      recordedAt: json['recorded_at'] != null 
          ? DateTime.parse(json['recorded_at'] as String)
          : DateTime.now(),
      userPrompt: json['user_prompt'] as String?,
      plan: json['ai_response_data'] != null 
          ? WorkoutPlan.fromJson(json['ai_response_data'] as Map<String, dynamic>)
          : null,
      healthContext: json['health_context_snapshot'] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'recorded_at': recordedAt.toIso8601String(),
      'user_prompt': userPrompt,
      'ai_response_data': plan?.toJson(),
      'health_context_snapshot': healthContext,
    };
  }

  AISuggestionHistory copyWith({
    int? id,
    DateTime? recordedAt,
    String? userPrompt,
    WorkoutPlan? plan,
    Map<String, dynamic>? healthContext,
  }) {
    return AISuggestionHistory(
      id: id ?? this.id,
      recordedAt: recordedAt ?? this.recordedAt,
      userPrompt: userPrompt ?? this.userPrompt,
      plan: plan ?? this.plan,
      healthContext: healthContext ?? this.healthContext,
    );
  }
}
