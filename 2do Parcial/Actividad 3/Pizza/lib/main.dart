import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'screens/splash_screen.dart';
import 'screens/login_screen.dart';
import 'screens/register_screen.dart';
import 'screens/buyer/buyer_home.dart';
import 'screens/seller/seller_home.dart';
import 'screens/common/not_found_screen.dart';
import 'supabase_config.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SupabaseConfig.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Pizzería',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepOrange),
        useMaterial3: true,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return _r(const SplashScreen(), settings);
          case '/login':
            return _r(const LoginScreen(), settings);
          case '/registro':
            return _r(const RegisterScreen(), settings);
          case '/comprador':
            return _r(const BuyerHome(), settings);
          case '/vendedor':
            return _r(const SellerHome(), settings);
          default:
            return _r(const NotFoundScreen(), settings);
        }
      },
    );
  }

  static MaterialPageRoute _r(Widget child, RouteSettings s) =>
      MaterialPageRoute(builder: (_) => child, settings: s);
}