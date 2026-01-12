import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/exercise.dart';

class ExerciseRepository {
  final SupabaseClient _supabase = Supabase.instance.client;

  /// Chuyển đổi storage path thành public URL nếu cần
  String? _convertToPublicUrl(String? url, String bucketName) {
    if (url == null || url.isEmpty) {
      debugPrint('⚠️ URL rỗng hoặc null');
      return null;
    }
    
    // Trim whitespace
    url = url.trim();
    
    // Nếu đã là full URL (bắt đầu với http/https), trả về nguyên
    if (url.startsWith('http://') || url.startsWith('https://')) {
      debugPrint('✅ animation_url đã là full URL: $url');
      return url;
    }
    
    // Nếu là storage path, chuyển đổi thành public URL
    try {
      // Đảm bảo path không bắt đầu bằng /
      final cleanPath = url.startsWith('/') ? url.substring(1) : url;
      final publicUrl = _supabase.storage.from(bucketName).getPublicUrl(cleanPath);
      debugPrint('🔄 Chuyển đổi storage path: $url -> $publicUrl');
      return publicUrl;
    } catch (e, stackTrace) {
      // Nếu lỗi, log chi tiết và trả về URL gốc
      debugPrint('⚠️ Lỗi chuyển đổi URL: $e');
      debugPrint('📎 URL gốc: $url');
      debugPrint('📦 Bucket: $bucketName');
      debugPrint('📚 StackTrace: $stackTrace');
      return url;
    }
  }

  /// Xử lý và chuyển đổi URLs trong JSON response
  Map<String, dynamic> _processExerciseJson(Map<String, dynamic> json) {
    final processed = Map<String, dynamic>.from(json);
    
    // Chuyển đổi animation_url nếu có
    if (processed['animation_url'] != null) {
      processed['animation_url'] = _convertToPublicUrl(
        processed['animation_url'] as String?,
        'exercises', // bucket name cho exercises
      );
    }
    
    // Chuyển đổi thumbnail_url nếu có
    if (processed['thumbnail_url'] != null) {
      processed['thumbnail_url'] = _convertToPublicUrl(
        processed['thumbnail_url'] as String?,
        'exercises',
      );
    }
    
    return processed;
  }

  Future<List<Exercise>> getExercises() async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .order('id', ascending: true);

      return (response as List)
          .map((json) => Exercise.fromJson(_processExerciseJson(json as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tải danh sách bài tập: $e');
    }
  }

  Future<Exercise?> getExerciseById(int id) async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .eq('id', id)
          .single();

      return Exercise.fromJson(_processExerciseJson(response));
    } catch (e) {
      throw Exception('Lỗi khi tải bài tập: $e');
    }
  }

  Future<List<Exercise>> searchExercises(String query) async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .ilike('name', '%$query%')
          .order('id', ascending: true);

      return (response as List)
          .map((json) => Exercise.fromJson(_processExerciseJson(json as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tìm kiếm bài tập: $e');
    }
  }

  Future<List<Exercise>> getExercisesByMuscleGroup(String muscleGroup) async {
    try {
      final response = await _supabase
          .from('exercises')
          .select()
          .ilike('muscle_group', '%$muscleGroup%')
          .order('id', ascending: true);

      return (response as List)
          .map((json) => Exercise.fromJson(_processExerciseJson(json as Map<String, dynamic>)))
          .toList();
    } catch (e) {
      throw Exception('Lỗi khi tải bài tập theo nhóm cơ: $e');
    }
  }
}
