import 'package:supabase_flutter/supabase_flutter.dart';
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
    double tempHeight = 0.0;
    int tempAge = 0;

    try {
      final profileData = await _supabase.from('profiles').select('height, date_of_birth').eq('id', userId).maybeSingle();
      if (profileData != null) {
        if (profileData['height'] != null) {
          tempHeight = (profileData['height'] as num).toDouble();
        }
        if (profileData['date_of_birth'] != null) {
           final dob = DateTime.parse(profileData['date_of_birth']);
           tempAge = DateTime.now().year - dob.year;
        }
      }

      final healthData = await _supabase.from('health').select('weight').eq('user_id', userId).maybeSingle();
      if (healthData != null) {
        if (healthData['weight'] != null) {
           tempWeight = (healthData['weight'] as num).toDouble();
        }
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
      height: tempHeight,               
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

  Future<void> saveProfile(String userId, double weight, double height, int age) async {
    try {
      await _supabase.from('health').upsert({'user_id': userId,'weight': weight,'age': age,}).eq('user_id', userId);
      await _supabase.from('profiles').update({'height': height}).eq('id', userId);
    } catch (e, st) {
      throw handleException(e, st);
    }
  }
}
