import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../supabase_config.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _check();
  }

  Future<void> _check() async {
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;

    final session = supabase.auth.currentSession;
    if (session == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }

    try {
      await supabase.auth.refreshSession();
    } catch (_) {}

    if (!mounted) return;
    if (AuthService.isLoggedIn) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.place, size: 100, color: Colors.deepPurple),
            SizedBox(height: 16),
            Text(
              'Mis Lugares',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}