import 'package:flutter/material.dart';
import '../supabase_config.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _form = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _cargando = false;

  Future<void> _login() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _cargando = true);
    try {
      final res = await supabase.auth.signInWithPassword(
        email: _email.text.trim(),
        password: _pass.text,
      );
      final uid = res.user!.id;
      final perfil = await supabase
          .from('profiles')
          .select()
          .eq('id', uid)
          .maybeSingle();
      final rol = perfil?['role'] ?? 'comprador';
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        rol == 'vendedor' ? '/vendedor' : '/comprador',
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Iniciar sesión')),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _form,
            child: Column(
              children: [
                const Icon(Icons.local_pizza, size: 72, color: Colors.deepOrange),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _email,
                  decoration: const InputDecoration(
                    labelText: 'Correo',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  validator: (v) =>
                      (v == null || !v.contains('@')) ? 'Correo inválido' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _pass,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.lock),
                  ),
                  validator: (v) =>
                      (v == null || v.length < 6) ? 'Mínimo 6 caracteres' : null,
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _cargando ? null : _login,
                    child: _cargando
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2))
                        : const Text('Entrar'),
                  ),
                ),
                TextButton(
                  onPressed: () =>
                      Navigator.pushNamed(context, '/registro'),
                  child: const Text('Crear cuenta'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}