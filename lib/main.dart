import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:logger/logger.dart';
import 'dart:async';
import 'config/supabase_config.dart';
import 'constants/app_constants.dart';
import 'screens/auth/login_screen.dart';
import 'screens/health_onboard/health_onboarding_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/workouts/workouts_screen.dart';
import 'screens/progress/progress_screen.dart';
import 'screens/health/health_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'providers/auth_provider.dart';
import 'providers/health_provider.dart';
import 'widgets/bottom_nav.dart';
import 'package:awesome_notifications/awesome_notifications.dart'; // Import thư viện
import 'package:device_preview/device_preview.dart';
import 'services/notification_service.dart';

final logger = Logger();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await dotenv.load(fileName: '.env');
  } catch (e) {
    logger.w('⚠️ Warning: .env file not found. Using fallback values.');
  }
  
  logger.i('Starting Workout App...');
  
  // Kiểm tra config
  if (!SupabaseConfig.isValid()) {
    logger.e('❌ Supabase config không hợp lệ!');
    return;
  }
  
  try {
    await Supabase.initialize(
      url: SupabaseConfig.supabaseUrl,
      anonKey: SupabaseConfig.supabaseAnonKey,
    ).timeout(
      const Duration(seconds: 10),
      onTimeout: () => throw TimeoutException('Supabase initialization timeout', null),
    );
    logger.i('✅ Supabase initialized successfully');
  } catch (e) {
    logger.e('❌ Error initializing Supabase: $e');
    // Không rethrow để app vẫn chạy tiếp được (có thể hiện màn hình lỗi sau)
  }
  
  await AwesomeNotifications().initialize(
      null, // null = dùng icon mặc định của app
      [
        NotificationChannel(
          channelGroupKey: NotificationService.waterChannelGroupKey,
          channelKey: NotificationService.waterChannelKey, 
          channelName: 'Nhắc nhở uống nước',
          channelDescription: 'Thông báo nhắc bạn uống nước đều đặn',
          defaultColor: const Color(0xFF9D50DD),
          ledColor: Colors.white,
          importance: NotificationImportance.High, 
          channelShowBadge: true,
          playSound: true,
        )
      ],
      debug: true,
  );

  runApp(
    DevicePreview(
      enabled: true, // Set false khi build thật
      builder: (context) => const ProviderScope(
        child: MyApp(),
      ),
    ),
  );
}

// --- 2. THÊM CLASS XỬ LÝ SỰ KIỆN (CONTROLLER) ---
class NotificationController {
  @pragma("vm:entry-point")
  static Future <void> onActionReceivedMethod(ReceivedAction receivedAction) async {
    if(receivedAction.buttonKeyPressed == 'DRANK_WATER'){
        debugPrint("User đã bấm: Đã uống nước! (Logic update DB sẽ nằm ở đây)");
    }
  }

  @pragma("vm:entry-point") 
  static Future <void> onNotificationCreatedMethod(ReceivedNotification receivedNotification) async {
    debugPrint("🔔 Notification Created: ${receivedNotification.title} (ID: ${receivedNotification.id})");
  }

  @pragma("vm:entry-point") 
  static Future <void> onNotificationDisplayedMethod(ReceivedNotification receivedNotification) async {
    debugPrint("📱 Notification Displayed: ${receivedNotification.title} (ID: ${receivedNotification.id})");
  }
  @pragma("vm:entry-point") static Future <void> onDismissActionReceivedMethod(ReceivedAction receivedAction) async {}
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
    
    // --- 3. ĐĂNG KÝ LẮNG NGHE SỰ KIỆN & XIN QUYỀN ---
    
    // Đăng ký listener
    AwesomeNotifications().setListeners(
        onActionReceivedMethod:         NotificationController.onActionReceivedMethod,
        onNotificationCreatedMethod:    NotificationController.onNotificationCreatedMethod,
        onNotificationDisplayedMethod:  NotificationController.onNotificationDisplayedMethod,
        onDismissActionReceivedMethod:  NotificationController.onDismissActionReceivedMethod
    );

    // Xin quyền gửi thông báo (Quan trọng cho Android 13+)
    AwesomeNotifications().isNotificationAllowed().then((isAllowed) {
      if (!isAllowed) {
        AwesomeNotifications().requestPermissionToSendNotifications();
      }
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authStateAsync = ref.watch(authStateProvider);
    final hasHealthDataAsync = ref.watch(hasHealthDataProvider);
    
    // Lưu ý: Đã init notification ở initState, không cần gọi provider init ở đây nữa để tránh duplicate
    
    return MaterialApp(
      title: 'Workout App',
      debugShowCheckedModeBanner: false,
      locale: DevicePreview.locale(context),
      builder: DevicePreview.appBuilder,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: AppColors.bgLight,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.black,
        ),
      ),
      home: _buildHome(authStateAsync, hasHealthDataAsync),
    );
  }

  Widget _buildHome(AsyncValue<bool> authState, AsyncValue<bool> hasHealthData) {
    // 1. Kiểm tra xác thực (Auth)
    // Chỉ hiện loading nếu thực sự lần đầu không có dữ liệu (hasValue == false)
    if (authState.isLoading && !authState.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // .value trả về giá trị hiện tại (kể cả khi đang loading ngầm)
    final isAuthenticated = authState.value ?? false;
    if (!isAuthenticated) {
      return LoginScreen(
        onLoginSuccess: () async {
          ref.invalidate(healthDataProvider);
          ref.invalidate(hasHealthDataProvider);
        },
      );
    }

    // 2. Kiểm tra dữ liệu sức khỏe (Health Data)
    // Nhờ việc tách provider ở health_provider.dart, hasHealthData sẽ không bị refresh
    // mỗi khi healthDataProvider thay đổi nữa.
    if (hasHealthData.isLoading && !hasHealthData.hasValue) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final hasData = hasHealthData.value ?? false;
    if (!hasData) {
      return HealthOnboardingScreen(
        onComplete: () async {
          ref.invalidate(healthDataProvider);
          ref.invalidate(hasHealthDataProvider);
        },
      );
    }

    // 3. App Shell chính - Tuyệt đối không bị unmount khi update settings
    return const AppShell();
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

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
      case 'home': return const HomeScreen();
      case 'workouts': return const WorkoutsScreen();
      case 'progress': return const ProgressScreen();
      case 'health': return const HealthScreen();
      case 'profile': return const ProfileScreen();
      default: return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(child: _buildScreen(_activeTab)),
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