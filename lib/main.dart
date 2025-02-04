import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:grocerry/firebase/notification/fcm_service.dart';
import 'package:grocerry/firebase/notification/notification_service.dart';
import 'package:grocerry/firebase/user_service.dart';
import 'package:grocerry/firebase_options.dart';
import 'package:grocerry/notifier/address_provider.dart';
import 'package:grocerry/notifier/cart_notifier.dart';
import 'package:grocerry/screens/service_un_avl.dart';
import 'package:grocerry/utils/forced_up.dart';
import 'package:grocerry/utils/utility.dart';
import 'package:provider/provider.dart';
import 'notifier/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.initializeNotification();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await FCMService().requestNotificationPermission();
  await FCMService().initializeFCM();
  Utility.i();
  final updateManager = UpdateManager();
  await updateManager.initialize();
  runApp(MyApp(updateManager: updateManager));
}

class MyApp extends StatelessWidget {
  final UpdateManager updateManager;
  const MyApp({super.key, required this.updateManager});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => CartNotifier()..loadCart(),
        ),
        ChangeNotifierProvider(
          create: (context) => AuthProviderC(),
        ),
        ChangeNotifierProvider(create: (_) => AddressProvider()),
      ],
      child: GetMaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Phone Auth App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.grey[100],
          snackBarTheme: const SnackBarThemeData(
            behavior: SnackBarBehavior.floating,
          ),
        ),
        home: Builder(
          builder: (context) {
            updateManager.shouldForceUpdate(context);
            return AuthWrapper();
          },
        ),
      ),
    );
  }
}

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  UserService userService = UserService();
  final FirebaseRemoteConfig _remoteConfig = FirebaseRemoteConfig.instance;

  @override
  void initState() {
    super.initState();
    _initializeRemoteConfig();
  }

  Future<void> _initializeRemoteConfig() async {
    try {
      await _remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(minutes: 1),
        minimumFetchInterval: const Duration(hours: 1),
      ));
      await _remoteConfig.fetchAndActivate();
    } catch (e) {
      debugPrint('Error initializing remote config: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderC>(
      builder: (context, auth, _) {
        return StreamBuilder<User?>(
          stream: auth.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }

            // Check if service is out of service
            final isOutOfService = _remoteConfig.getBool('is_out_of_service');
            if (isOutOfService) {
              return const ServiceUnavailablePage();
            }

            if (snapshot.hasData) {
              return HomeScreen();
            }

            return LoginScreen();
          },
        );
      },
    );
  }
}
