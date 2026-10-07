import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
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
    _irAInicio();
  }

  Future<void> _irAInicio() async {
    await Future.delayed(const Duration(milliseconds: 600));
    final session = supabase.auth.currentSession;
    if (!mounted) return;
    if (session == null) {
      Navigator.pushReplacementNamed(context, '/login');
      return;
    }
    try {
      final perfil = await supabase
          .from('profiles')
          .select()
          .eq('id', session.user.id)
          .maybeSingle();
      final rol = perfil?['role'] ?? 'comprador';
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        rol == 'vendedor' ? '/vendedor' : '/comprador',
      );
    } catch (_) {
      if (!mounted) return;
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
            Icon(Icons.local_pizza, size: 96, color: Colors.deepOrange),
            SizedBox(height: 16),
            Text('Pizzería', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}