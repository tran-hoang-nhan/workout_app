import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';
import '../models/user.dart';

// Auth Service Provider
final authServiceProvider = Provider<AuthService>((ref) {
  return AuthService();
});

// Current authenticated user ID provider
final currentUserIdProvider = StreamProvider<String?>((ref) async* {
  final authService = ref.watch(authServiceProvider);
  
  // Listen to auth state changes from the start
  await for (final state in authService.authStateStream) {
    final userId = state.session?.user.id;
    debugPrint('[currentUserIdProvider] Auth state changed, userId: $userId');
    yield userId;
  }
});

// Full user profile provider - loads from Supabase when user ID changes
final currentUserProvider = FutureProvider<AppUser?>((ref) async {
  final userId = await ref.watch(currentUserIdProvider.future);
  
  if (userId == null) {
    debugPrint('[currentUserProvider] No user ID, returning null');
    return null;
  }
  
  final authService = ref.watch(authServiceProvider);
  debugPrint('[currentUserProvider] Loading full profile for user: $userId');
  
  try {
    final profile = await authService.getUserProfile(userId);
    debugPrint('[currentUserProvider] Profile loaded: ${profile?.fullName}, height: ${profile?.height}, goal: ${profile?.goal}');
    return profile;
  } catch (e) {
    debugPrint('[currentUserProvider] Error loading profile: $e');
    return null;
  }
});

// Auth State Provider
final authStateProvider = StreamProvider<bool>((ref) async* {
  final authService = ref.watch(authServiceProvider);
  
  yield authService.isAuthenticated;
  
  await for (final state in authService.authStateStream) {
    yield state.session != null;
  }
});

// User Profile Provider - alternative family provider
final userProfileProvider = FutureProvider.family<AppUser?, String>((ref, userId) async {
  final authService = ref.watch(authServiceProvider);
  return await authService.getUserProfile(userId);
});
