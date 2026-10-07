import 'package:flutter/material.dart';
import '../../supabase_config.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _nombre = TextEditingController();
  final _email = TextEditingController();
  bool _cargando = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargar();
  }

  Future<void> _cargar() async {
    try {
      final uid = supabase.auth.currentUser!.id;
      final perfil = await supabase
          .from('profiles')
          .select()
          .eq('id', uid)
          .single();
      _nombre.text = perfil['full_name'] ?? '';
      _email.text = perfil['email'] ?? '';
    } catch (_) {}
    if (mounted) setState(() => _cargando = false);
  }

  Future<void> _guardar() async {
    setState(() => _guardando = true);
    try {
      final uid = supabase.auth.currentUser!.id;
      await supabase
          .from('profiles')
          .update({'full_name': _nombre.text.trim()}).eq('id', uid);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Datos actualizados')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Center(child: CircularProgressIndicator());
    }
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const Icon(Icons.person, size: 80),
        const SizedBox(height: 16),
        TextField(
          controller: _nombre,
          decoration: const InputDecoration(
            labelText: 'Nombre completo',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _email,
          enabled: false,
          decoration: const InputDecoration(
            labelText: 'Correo',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 20),
        FilledButton(
          onPressed: _guardando ? null : _guardar,
          child: const Text('Guardar cambios'),
        ),
      ],
    );
  }
}