import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'config/supabase_config.dart';
import 'constants/app_constants.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/workouts/workouts_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'screens/health/health_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'providers/auth_provider.dart';
import 'widgets/bottom_nav.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load .env file (gracefully handle if not found on mobile)
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    logger.w('⚠️ Warning: .env file not found. Using fallback values.');
  }
  
  logger.i('Starting Workout App...');
  logger.i(SupabaseConfig.debugInfo());
  
  // Kiểm tra config
  if (!SupabaseConfig.isValid()) {
    logger.e('❌ Supabase config không hợp lệ!');
    logger.e('Vui lòng kiểm tra file .env hoặc environment variables');
    return;
  }
  
  try {
    // Khởi tạo Supabase với timeout cho web
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('Supabase initialization timeout', null),
    );
    logger.i('✅ Supabase initialized successfully');
  } on TimeoutException catch (e) {
    logger.w('⚠️ Supabase initialization timeout on web: $e');
    // Continue app even if Supabase initialization times out on web
  } catch (e) {
    logger.e('❌ Error initializing Supabase: $e');
    rethrow;
  }
  
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerStatefulWidget {
  const MyApp({super.key});

  @override
  ConsumerState<MyApp> createState() => _MyAppState();
}

class _MyAppState extends ConsumerState<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch auth state - this will rebuild when it changes
    final authStateAsync = ref.watch(authStateProvider);

    return MaterialApp(
      title: 'Workout App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.dark,
        ),
        scaffoldBackgroundColor: const Color(0xFF000000),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Color(0xFF000000),
          foregroundColor: AppColors.white,
        ),
      ),
      home: authStateAsync.when(
        data: (isAuthenticated) {
          return isAuthenticated 
            ? const AppShell() 
            : LoginScreen(
                onLoginSuccess: () {
                  // Invalidate auth state to trigger rebuild
                  ref.invalidate(authStateProvider);
                  ref.invalidate(currentUserIdProvider);
                  ref.invalidate(currentUserProvider);
                },
              );
        },
        loading: () => const Scaffold(
          body: Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
        ),
        error: (error, stackTrace) => LoginScreen(
          onLoginSuccess: () {
            ref.invalidate(authStateProvider);
          },
        ),
      ),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({Key? key}) : super(key: key);

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  String _activeTab = 'home';

  void _setActiveTab(String tabId) {
    setState(() => _activeTab = tabId);
  }

  Widget _buildScreen(String tabId) {
    switch (tabId) {
      case 'home':
        return const HomeScreen();
      case 'workouts':
        return const WorkoutsScreen();
      case 'progress':
        return const ProgressScreen();
      case 'health':
        return const HealthScreen();
      case 'profile':
        return const ProfileScreen();
      default:
        return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _buildScreen(_activeTab),
              ),
            ],
          ),
          BottomNav(
            activeTab: _activeTab,
            setActiveTab: _setActiveTab,
          ),
        ],
      ),
    );
  }
}

