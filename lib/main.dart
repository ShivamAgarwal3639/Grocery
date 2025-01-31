import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:grocerry/notifier/address_provider.dart';
import 'package:grocerry/notifier/cart_notifier.dart';
import 'package:grocerry/utils/forced_up.dart';
import 'package:provider/provider.dart';
import 'notifier/auth_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
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

class AuthWrapper extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProviderC>(
      builder: (context, auth, _) {
        return StreamBuilder(
          stream: auth.authStateChanges,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
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
