import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'screens/signup_screen.dart';
import 'screens/login_screen.dart';
import 'screens/parent_dashboard_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/reset_password_screen.dart';
import 'screens/splash_screen.dart';
import 'screens/specialist_dashboard_screen.dart';
import 'screens/full_vacation_request_screen.dart';
import 'screens/chat_list_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'services/notification_service.dart';
import 'services/auth_sync_service.dart';
import 'services/complete_notification_service.dart';

// 🔥 FirebaseOptions للويب
const firebaseWebOptions = FirebaseOptions(
  apiKey: "AIzaSyATyDfeHwkbDNj02dZcxSafKT_V43ni0wQ",
  authDomain: "jusoor-eb6d3.firebaseapp.com",
  projectId: "jusoor-eb6d3",
  storageBucket: "jusoor-eb6d3.firebasestorage.app",
  messagingSenderId: "576013693747",
  appId: "1:576013693747:web:8c45cbfa9b10009796c446",
  measurementId: "G-Y33PDKTVJD",
);

// دالة الخلفية
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  if (!kIsWeb) {
    await Firebase.initializeApp();
    print("📋 Background message received: ${message.messageId}");
    await CompleteNotificationService.handleBackgroundMessage(message);
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  print('🚀 بدء تشغيل تطبيق Jusoor...');

  // 🔥 تهيئة Firebase مع options مختلفة للويب
  if (kIsWeb) {
    await Firebase.initializeApp(options: firebaseWebOptions);
  } else {
    await Firebase.initializeApp();
  }

  // مزامنة المستخدم مع Firebase
  await _syncUserWithFirebase();

  // تهيئة الإشعارات بس للموبايل
  if (!kIsWeb) {
    try {
      await CompleteNotificationService().initializeCompleteNotifications();
      print('✅ النظام الكامل للإشعارات جاهز');
    } catch (e) {
      print('⚠️ استخدام النظام القديم للإشعارات بسبب: $e');
      await initializeNotifications();
    }

    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    FirebaseMessaging messaging = FirebaseMessaging.instance;
    String? token = await messaging.getToken();
    print("📱 Device Token: $token");
  } else {
    print('🌐 تشغيل على الويب - تم تخطي إعدادات الإشعارات');

    try {
      FirebaseMessaging messaging = FirebaseMessaging.instance;
      String? token = await messaging.getToken();
      print("🌐 Web Token: $token");
    } catch (e) {
      print('⚠️ لا يمكن الحصول على token للويب: $e');
    }
  }

  runApp(MyApp());
}

// دالة المزامنة مع Firebase
Future<void> _syncUserWithFirebase() async {
  try {
    final authSync = AuthSyncService();
    await authSync.syncCurrentUser();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      print('🎯 Firebase sync successful: ${user.uid}');
    } else {
      print('⚠️ No user logged in to Firebase');
    }
  } catch (e) {
    print('❌ Firebase sync failed: $e');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  final CompleteNotificationService _notificationService = CompleteNotificationService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    print('📱 بدء متابعة حالة التطبيق');
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!kIsWeb) {
      switch (state) {
        case AppLifecycleState.resumed:
          _notificationService.updateAppState(true);
          print('📱 التطبيق في المقدمة');
          break;
        case AppLifecycleState.paused:
        case AppLifecycleState.inactive:
          _notificationService.updateAppState(false);
          print('📱 التطبيق في الخلفية');
          break;
        case AppLifecycleState.detached:
          print('📱 التطبيق مغلق');
          break;
        case AppLifecycleState.hidden:
          print('📱 التطبيق مخفي');
          _notificationService.updateAppState(false);
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jusoor App',
      theme: ThemeData(primarySwatch: Colors.blue),
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => SplashScreen(),
        '/signup': (context) => SignupScreen(),
        '/login': (context) => LoginScreen(),
        '/parentDashboard': (context) => ParentDashboardScreen(),
        '/vacation': (context) => VacationRequestScreen(),
        '/forgotPassword': (context) => ForgotPasswordScreen(),
        '/specialistDashboard': (context) => SpecialistDashboardScreen(),
        '/chats': (context) => ChatListScreen(),
        '/resetPassword': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return ResetPasswordScreen(email: args['email'], code: args['code']);
        },
      },
      debugShowCheckedModeBanner: false,
    );
  }
}