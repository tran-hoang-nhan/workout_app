import '../models/auth.dart';
import '../models/health_params.dart';
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import '../repositories/health_repository.dart';
import '../utils/app_error.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class RegistrationTransactionService {
  final AuthRepository _authRepo;
  final HealthRepository _healthRepo;
  final SupabaseClient _supabase;
  RegistrationTransactionService({ AuthRepository? authRepo, HealthRepository? healthRepo,}):
    _authRepo = authRepo ?? AuthRepository(),
    _healthRepo = healthRepo ?? HealthRepository(),
    _supabase = Supabase.instance.client;

  Future<AppUser?> completeRegistration({ required SignUpParams signUpParams, required HealthUpdateParams healthParams,}) async {
    String? createdUserId;
    bool profileCreated = false;
    try {
      // Step 1 & 2: Create auth user + profile
      final user = await _authRepo.signUpWithTransaction(signUpParams);
      if (user == null) {
        throw AppError('Failed to create user');
      }
      createdUserId = user.id;
      profileCreated = true;
      print('Auth + Profile created');

      // Step 3: Create health data with correct userId
      final healthParamsWithUserId = HealthUpdateParams(
        userId: createdUserId,
        age: healthParams.age,
        weight: healthParams.weight,
        height: healthParams.height,
        gender: healthParams.gender,
        activityLevel: healthParams.activityLevel,
        goal: healthParams.goal,
        dietType: healthParams.dietType,
        sleepHours: healthParams.sleepHours,
        waterIntake: healthParams.waterIntake,
        injuries: healthParams.injuries,
        medicalConditions: healthParams.medicalConditions,
        allergies: healthParams.allergies,
        waterReminderEnabled: healthParams.waterReminderEnabled,
        waterReminderInterval: healthParams.waterReminderInterval,
      );
      
      await _healthRepo.saveHealthDataWithTransaction(healthParamsWithUserId);
      print('✅ Health data created');
      return user;
    } catch (e, st) {
      if (profileCreated && createdUserId != null) {
        try {
          await _supabase.from('profiles').delete().eq('id', createdUserId);
          await _supabase.from('health').delete().eq('user_id', createdUserId);
          print('Rolled back profile and health');
        } catch (rollbackError) {
          print('⚠️ Rollback failed: $rollbackError');
        }
      }
      throw handleException(e, st);
    }
  }
}
