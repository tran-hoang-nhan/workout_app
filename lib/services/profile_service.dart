import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class UserStats {
  final int totalWorkouts;
  final double totalHours;
  final int totalCalories;
  final int streak;
  double weight;
  double height;
  int age;

  UserStats({
    required this.totalWorkouts,
    required this.totalHours,
    required this.totalCalories,
    required this.streak,
    required this.weight,
    required this.height,
    required this.age,
  });

  UserStats copyWith({
    int? totalWorkouts,
    double? totalHours,
    int? totalCalories,
    int? streak,
    double? weight,
    double? height,
    int? age,
  }) {
    return UserStats(
      totalWorkouts: totalWorkouts ?? this.totalWorkouts,
      totalHours: totalHours ?? this.totalHours,
      totalCalories: totalCalories ?? this.totalCalories,
      streak: streak ?? this.streak,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
    );
  }
}

class UserProfile {
  final String userId;
  final String email;
  final String name;
  final String createdAt;

  UserProfile({
    required this.userId,
    required this.email,
    required this.name,
    required this.createdAt,
  });
}

class ProfileService {
  final supabase = Supabase.instance.client;

  // Check current session
  Future<UserProfile?> checkSession() async {
    try {
      final session = supabase.auth.currentSession;

      if (session != null) {
        return UserProfile(
          userId: session.user.id,
          email: session.user.email ?? '',
          name: session.user.userMetadata?['name'] ?? 'Người dùng',
          createdAt: session.user.createdAt,
        );
      }
      return null;
    } catch (e) {
      debugPrint('Error checking session: $e');
      return null;
    }
  }

  // Load user health and profile data
  Future<UserStats> loadUserHealthData(String userId) async {
    try {
      UserStats stats = UserStats(
        totalWorkouts: 142,
        totalHours: 86.5,
        totalCalories: 45200,
        streak: 12,
        weight: 68,
        height: 175,
        age: 28,
      );

      // Fetch height from profiles table
      try {
        final profileData = await supabase
            .from('profiles')
            .select('height')
            .eq('id', userId)
            .single();

        stats.height = (profileData['height'] as num).toDouble();
      } catch (e) {
        debugPrint('Profile data not found: $e');
      }

      // Fetch age and weight from health table
      try {
        final healthData = await supabase
            .from('health')
            .select('age, weight')
            .eq('user_id', userId)
            .single();

        stats.age = healthData['age'] as int;
        stats.weight = (healthData['weight'] as num).toDouble();
      } catch (e) {
        debugPrint('Health data not found: $e');
      }

      return stats;
    } catch (e) {
      debugPrint('Error loading user health data: $e');
      return UserStats(
        totalWorkouts: 142,
        totalHours: 86.5,
        totalCalories: 45200,
        streak: 12,
        weight: 68,
        height: 175,
        age: 28,
      );
    }
  }

  // Login with email and password
  Future<({UserProfile? profile, UserStats? stats, String? error})> login(
      String email, String password) async {
    try {
      final response = await supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null) {
        return (profile: null, stats: null, error: 'Đăng nhập thất bại');
      }

      final user = response.session!.user;
      final profile = UserProfile(
        userId: user.id,
        email: user.email ?? '',
        name: user.userMetadata?['name'] ?? 'Người dùng',
        createdAt: user.createdAt,
      );

      final stats = await loadUserHealthData(user.id);

      return (profile: profile, stats: stats, error: null);
    } catch (e) {
      return (profile: null, stats: null, error: e.toString());
    }
  }

  // Signup with email, password and name
  Future<({UserProfile? profile, UserStats? stats, String? error})> signup(
      String email, String password, String name) async {
    try {
      final response = await supabase.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.session == null) {
        return (profile: null, stats: null, error: 'Đăng ký thất bại');
      }

      final user = response.session!.user;
      final profile = UserProfile(
        userId: user.id,
        email: user.email ?? '',
        name: user.userMetadata?['name'] ?? 'Người dùng',
        createdAt: user.createdAt,
      );

      final stats = await loadUserHealthData(user.id);

      return (profile: profile, stats: stats, error: null);
    } catch (e) {
      return (profile: null, stats: null, error: e.toString());
    }
  }

  // Logout
  Future<String?> logout() async {
    try {
      await supabase.auth.signOut();
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  // Save profile changes to database
  Future<({UserStats? stats, String? error})> saveProfile(
    String userId,
    double weight,
    double height,
    int age,
  ) async {
    try {
      // Update health table
      await supabase
          .from('health')
          .upsert({
            'user_id': userId,
            'weight': weight,
            'age': age,
          })
          .eq('user_id', userId);

      // Update profiles table
      await supabase
          .from('profiles')
          .update({'height': height})
          .eq('id', userId);

      // Return updated stats
      final stats = await loadUserHealthData(userId);
      return (stats: stats, error: null);
    } catch (e) {
      return (stats: null, error: e.toString());
    }
  }

  // Format date for display
  String formatDate(String dateString) {
    if (dateString.isEmpty) return '';
    try {
      final date = DateTime.parse(dateString);
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return '';
    }
  }
}
