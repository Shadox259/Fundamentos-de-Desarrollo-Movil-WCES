import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../services/places_service.dart';
import '../supabase_config.dart';

class ProfileScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  const ProfileScreen({super.key, required this.onToggleTheme});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int _total = 0;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _contar();
  }

  Future<void> _contar() async {
    try {
      final places = await PlacesService.fetchMyPlaces();
      setState(() => _total = places.length);
    } catch (_) {}
    if (mounted) setState(() => _cargando = false);
  }

  @override
  Widget build(BuildContext context) {
    final user = AuthService.currentUser;
    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        const SizedBox(height: 8),
        Center(
          child: CircleAvatar(
            radius: 48,
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            child: const Icon(Icons.person, size: 56),
          ),
        ),
        const SizedBox(height: 16),
        Center(
          child: Text(
            user?.email ?? 'Sin sesión',
            style: const TextStyle(fontSize: 16),
          ),
        ),
        const SizedBox(height: 24),
        Card(
          child: ListTile(
            leading: const Icon(Icons.place),
            title: const Text('Lugares guardados'),
            trailing: Text(
              _cargando ? '...' : '$_total',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Card(
          child: SwitchListTile(
            secondary: const Icon(Icons.dark_mode),
            title: const Text('Modo oscuro'),
            value: Theme.of(context).brightness == Brightness.dark,
            onChanged: (_) => widget.onToggleTheme(),
          ),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          icon: const Icon(Icons.logout, color: Colors.red),
          label: const Text(
            'Cerrar sesión',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () async {
            await AuthService.signOut();
            if (!context.mounted) return;
            Navigator.pushNamedAndRemoveUntil(
                context, '/login', (_) => false);
          },
        ),
      ],
    );
  }
}