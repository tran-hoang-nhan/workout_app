import 'package:supabase_flutter/supabase_flutter.dart';
import '../config/supabase_config.dart';
import '../models/user.dart';
import '../utils/app_error.dart';

class ProfileRepository {
  final SupabaseClient _supabase;
  ProfileRepository({SupabaseClient? supabase}): _supabase = supabase ?? Supabase.instance.client;

  Future<UserStats> loadUserHealthData(String userId) async {
    int tempTotalWorkouts = 0;
    double tempTotalHours = 0.0;
    int tempTotalCalories = 0;
    int tempStreak = 0;
    double tempWeight = 0.0;
    int tempAge = 0;
    try {
      final profileData = await _supabase.from('profiles').select('date_of_birth').eq('id', userId).maybeSingle();
      if (profileData != null && profileData['date_of_birth'] != null) {
        final dob = DateTime.parse(profileData['date_of_birth']);
        tempAge = DateTime.now().year - dob.year;
      }

      final healthData = await _supabase.from('health').select('weight').eq('user_id', userId).maybeSingle();
      if (healthData != null && healthData['weight'] != null) {
        tempWeight = (healthData['weight'] as num).toDouble();
      }
    } catch (e, st) {
      throw handleException(e, st);
    }
    return UserStats(
      totalWorkouts: tempTotalWorkouts,
      totalHours: tempTotalHours,
      totalCalories: tempTotalCalories,
      streak: tempStreak,
      weight: tempWeight,
      age: tempAge,
    );
  }

  Future<void> updateWeight(String userId, double newWeight) async {
    try {
      await _supabase.from('health').update({'weight': newWeight}).eq('user_id', userId);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<void> saveProfile({required String userId, required String fullName, String? gender, double? weight, DateTime? dateOfBirth, String? goal,}) async {
    try {
      // 1. Update profiles table
      final Map<String, dynamic> profileUpdates = {'full_name': fullName};
      if (gender != null) profileUpdates['gender'] = gender;
      if (goal != null) profileUpdates['goal'] = goal;
      if (dateOfBirth != null) {
        profileUpdates['date_of_birth'] = dateOfBirth.toIso8601String().split(
          'T',
        )[0];
      }

      await _supabase.from('profiles').update(profileUpdates).eq('id', userId);

      // 2. Update health table
      final Map<String, dynamic> healthUpdates = {};
      if (weight != null) healthUpdates['weight'] = weight;

      if (dateOfBirth != null) {
        final now = DateTime.now();
        int age = now.year - dateOfBirth.year;
        if (now.month < dateOfBirth.month ||
            (now.month == dateOfBirth.month && now.day < dateOfBirth.day)) {
          age--;
        }
        healthUpdates['age'] = age;
      }

      if (healthUpdates.isNotEmpty) {
        await _supabase.from('health').upsert({
          'user_id': userId,
          ...healthUpdates,
          'updated_at': DateTime.now().toIso8601String(),
        }, onConflict: 'user_id');
      }
    } catch (e, st) {
      throw handleException(e, st);
    }
  }

  Future<AppUser?> getFullUserProfile(String userId) async {
    try {
      final profileResponse = await _supabase.from(SupabaseConfig.profilesTable).select().eq('id', userId).maybeSingle();
      if (profileResponse == null) return null;

      final healthResponse = await _supabase.from('health').select('weight, height, age').eq('user_id', userId).maybeSingle();

      final userData = Map<String, dynamic>.from(profileResponse);
      if (healthResponse != null) {
        userData['weight'] = healthResponse['weight'];
        userData['height'] = healthResponse['height'];
        userData['age'] = healthResponse['age'];
      }
      return AppUser.fromJson(userData);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }
}
