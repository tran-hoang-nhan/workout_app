import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Cấu hình Supabase
/// Lấy từ file .env thay vì hardcode
class SupabaseConfig {
  // Lấy từ environment variables (.env file)
  static String get supabaseUrl {
    return dotenv.get('SUPABASE_URL', fallback: '');
  }

  static String get supabaseAnonKey {
    return dotenv.get('SUPABASE_ANON_KEY', fallback: '');
  }

  // Các endpoint và tên bảng
  static const String profilesTable = 'profiles';
  static const String workoutsTable = 'workouts';
  static const String exercisesTable = 'exercises';
  static const String storageUsersBucket = 'user-profiles';

  /// Kiểm tra config đã valid chưa
  static bool isValid() {
    return supabaseUrl.isNotEmpty && supabaseAnonKey.isNotEmpty;
  }

  /// Debug: In ra config (không in key đầy đủ vì security)
  static String debugInfo() {
    return '''
    Supabase Config:
    - URL: ${supabaseUrl.replaceRange(10, supabaseUrl.length, '***')}
    - Anon Key: ${supabaseAnonKey.replaceRange(0, 10, '***')}
    - Valid: ${isValid()}
    ''';
  }
}

