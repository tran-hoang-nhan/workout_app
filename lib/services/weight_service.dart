import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class WeightRecord {
  final int id;
  final String userId;
  final double weight;
  final double? bmi;
  final DateTime recordedAt;

  WeightRecord({
    required this.id,
    required this.userId,
    required this.weight,
    this.bmi,
    required this.recordedAt,
  });

  factory WeightRecord.fromJson(Map<String, dynamic> json) {
    return WeightRecord(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      weight: (json['weight'] as num).toDouble(),
      bmi: json['bmi'] != null ? (json['bmi'] as num).toDouble() : null,
      recordedAt: DateTime.parse(json['recorded_at'] as String),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'weight': weight,
      'bmi': bmi,
      'recorded_at': recordedAt.toIso8601String(),
    };
  }
}

class WeightService {
  final _supabase = Supabase.instance.client;

  Future<List<WeightRecord>> loadWeightHistory(String userId) async {
    try {
      debugPrint('[WeightService] Loading history for userId: $userId');
      final response = await _supabase
          .from('body_metrics')
          .select()
          .eq('user_id', userId)
          .order('recorded_at', ascending: false);

      debugPrint('[WeightService] Response: $response');
      final records = (response as List)
          .map((data) => WeightRecord.fromJson(data))
          .toList();
      debugPrint('[WeightService] Loaded ${records.length} records');
      return records;
    } catch (e) {
      debugPrint('[WeightService] Error loading weight history: $e');
      throw Exception('Error loading weight history: $e');
    }
  }

  Future<double?> loadHeightFromProfile(String userId) async {
    try {
      final response = await _supabase
          .from('profiles')
          .select('height')
          .eq('id', userId)
          .single();

      return (response['height'] as num?)?.toDouble();
    } catch (e) {
      return null;
    }
  }

  Future<void> addWeight({
    required String userId,
    required double weight,
    required double? bmi,
  }) async {
    try {
      // Check xem user đã có record trong body_metrics chưa
      final existing = await _supabase
          .from('body_metrics')
          .select('id')
          .eq('user_id', userId)
          .limit(1);

      if (existing.isNotEmpty) {
        // Update existing record
        await _supabase.from('body_metrics').update({
          'weight': weight,
          'bmi': bmi,
          'recorded_at': DateTime.now().toIso8601String(),
        }).eq('user_id', userId);
      } else {
        // Insert new record
        await _supabase.from('body_metrics').insert({
          'user_id': userId,
          'weight': weight,
          'bmi': bmi,
          'recorded_at': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      throw Exception('Error saving weight: $e');
    }
  }

  Future<void> deleteWeight(int id) async {
    try {
      await _supabase.from('body_metrics').delete().eq('id', id);
    } catch (e) {
      throw Exception('Error deleting weight: $e');
    }
  }

  // Calculate BMI
  double calculateBMI(double weight, double height) {
    final heightInMeters = height / 100;
    return weight / (heightInMeters * heightInMeters);
  }

  // Save weight with validation
  Future<void> saveWeight({
    required String userId,
    required double weight,
    required double height,
  }) async {
    final bmi = calculateBMI(weight, height);
    await addWeight(userId: userId, weight: weight, bmi: bmi);
  }
}
