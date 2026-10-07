import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://bzftmrippltciehkfeqr.supabase.co',
    anonKey: 'sb_publishable_2kj8Y9BP7mRhMymTOThjaQ_soYXEKaR',
  );
  runApp(const MyApp());
}

final supabase = Supabase.instance.client;

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Canciones CRUD',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CancionesPage(),
    );
  }
}

class CancionesPage extends StatefulWidget {
  const CancionesPage({super.key});

  @override
  State<CancionesPage> createState() => _CancionesPageState();
}

class _CancionesPageState extends State<CancionesPage> {
  List<Map<String, dynamic>> _canciones = [];
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarCanciones();
  }

  Future<void> _cargarCanciones() async {
    setState(() => _cargando = true);
    try {
      final data = await supabase
          .from('canciones')
          .select()
          .order('id', ascending: true);
      setState(() {
        _canciones = List<Map<String, dynamic>>.from(data);
      });
    } catch (e) {
      _snack('Error al cargar: $e', error: true);
    } finally {
      setState(() => _cargando = false);
    }
  }

  Future<void> _eliminar(int id, String titulo) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar canción'),
        content: Text('¿Seguro que quieres eliminar "$titulo"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    try {
      await supabase.from('canciones').delete().eq('id', id);
      _snack('Canción eliminada');
      _cargarCanciones();
    } catch (e) {
      _snack('Error al eliminar: $e', error: true);
    }
  }

  Future<void> _toggleFavorita(Map<String, dynamic> c) async {
    try {
      await supabase
          .from('canciones')
          .update({'favorita': !(c['favorita'] ?? false)})
          .eq('id', c['id']);
      _cargarCanciones();
    } catch (e) {
      _snack('Error al actualizar: $e', error: true);
    }
  }

  Future<void> _abrirFormulario({Map<String, dynamic>? cancion}) async {
    final guardado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => FormularioCancion(cancion: cancion),
      ),
    );
    if (guardado == true) _cargarCanciones();
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mis Canciones'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Recargar',
            onPressed: _cargarCanciones,
          ),
        ],
      ),
      body: _cargando
          ? const Center(child: CircularProgressIndicator())
          : _canciones.isEmpty
              ? const Center(
                  child: Text(
                    'No hay canciones.\nToca + para agregar una.',
                    textAlign: TextAlign.center,
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _cargarCanciones,
                  child: ListView.builder(
                    itemCount: _canciones.length,
                    itemBuilder: (context, i) {
                      final c = _canciones[i];
                      final favorita = c['favorita'] == true;

                      // Armamos el subtítulo con los campos opcionales
                      final partes = <String>[
                        c['artista']?.toString() ?? '',
                        if (c['album'] != null) c['album'].toString(),
                        if (c['anio'] != null) '${c['anio']}',
                        if (c['duracion_seg'] != null)
                          '${_formatearDuracion(c['duracion_seg'])}',
                      ];
                      final subtitulo = partes.where((s) => s.isNotEmpty).join(' • ');

                      return Card(
                        margin: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        child: ListTile(
                          leading: IconButton(
                            icon: Icon(
                              favorita ? Icons.favorite : Icons.favorite_border,
                              color: favorita ? Colors.red : Colors.grey,
                            ),
                            tooltip: favorita
                                ? 'Quitar de favoritas'
                                : 'Marcar como favorita',
                            onPressed: () => _toggleFavorita(c),
                          ),
                          title: Text(
                            c['titulo'] ?? '(sin título)',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(subtitulo),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.blue),
                                tooltip: 'Editar',
                                onPressed: () => _abrirFormulario(cancion: c),
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                tooltip: 'Eliminar',
                                onPressed: () =>
                                    _eliminar(c['id'], c['titulo'] ?? ''),
                              ),
                            ],
                          ),
                          onTap: () => _abrirFormulario(cancion: c),
                        ),
                      );
                    },
                  ),
                ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _abrirFormulario(),
        icon: const Icon(Icons.add),
        label: const Text('Agregar'),
      ),
    );
  }

  String _formatearDuracion(int segundos) {
    final m = segundos ~/ 60;
    final s = segundos % 60;
    return '$m:${s.toString().padLeft(2, '0')}';
  }
}

class FormularioCancion extends StatefulWidget {
  final Map<String, dynamic>? cancion; // null = crear, no-null = editar

  const FormularioCancion({super.key, this.cancion});

  @override
  State<FormularioCancion> createState() => _FormularioCancionState();
}

class _FormularioCancionState extends State<FormularioCancion> {
  final _formKey = GlobalKey<FormState>();

  final _tituloCtrl = TextEditingController();
  final _artistaCtrl = TextEditingController();
  final _albumCtrl = TextEditingController();
  final _anioCtrl = TextEditingController();
  final _duracionCtrl = TextEditingController();
  bool _favorita = false;
  bool _guardando = false;

  bool get _esEdicion => widget.cancion != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final c = widget.cancion!;
      _tituloCtrl.text = c['titulo']?.toString() ?? '';
      _artistaCtrl.text = c['artista']?.toString() ?? '';
      _albumCtrl.text = c['album']?.toString() ?? '';
      _anioCtrl.text = c['anio']?.toString() ?? '';
      _duracionCtrl.text = c['duracion_seg']?.toString() ?? '';
      _favorita = c['favorita'] == true;
    }
  }

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _artistaCtrl.dispose();
    _albumCtrl.dispose();
    _anioCtrl.dispose();
    _duracionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _guardando = true);

    final albumTexto = _albumCtrl.text.trim();

    final datos = <String, dynamic>{
      'titulo': _tituloCtrl.text.trim(),
      'artista': _artistaCtrl.text.trim(),
      'album': albumTexto.isEmpty ? null : albumTexto,
      'anio': _anioCtrl.text.trim().isEmpty
          ? null
          : int.parse(_anioCtrl.text.trim()),
      'duracion_seg': _duracionCtrl.text.trim().isEmpty
          ? null
          : int.parse(_duracionCtrl.text.trim()),
      'favorita': _favorita,
    };

    try {
      if (_esEdicion) {
        await supabase
            .from('canciones')
            .update(datos)
            .eq('id', widget.cancion!['id']);
      } else {
        await supabase.from('canciones').insert(datos);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
    } on PostgrestException catch (e) {
      _snack('Error de Supabase: ${e.message}', error: true);
    } catch (e) {
      _snack('Error inesperado: $e', error: true);
    } finally {
      if (mounted) setState(() => _guardando = false);
    }
  }

  void _snack(String msg, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: error ? Colors.red : null,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar canción' : 'Nueva canción'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _tituloCtrl,
              maxLength: 120,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Título *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.music_note),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requerido';
                if (v.trim().length > 120) return 'Máximo 120 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _artistaCtrl,
              maxLength: 120,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Artista *',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Requerido';
                if (v.trim().length > 120) return 'Máximo 120 caracteres';
                return null;
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _albumCtrl,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: 'Álbum (opcional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.album),
              ),
            ),
            const SizedBox(height: 12),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _anioCtrl,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Año',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return null;
                      final n = int.tryParse(t);
                      if (n == null) return 'Inválido';
                      if (n < 1900 || n > 2100) return 'Entre 1900 y 2100';
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _duracionCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Duración (seg)',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.timer),
                    ),
                    validator: (v) {
                      final t = v?.trim() ?? '';
                      if (t.isEmpty) return null;
                      final n = int.tryParse(t);
                      if (n == null) return 'Inválido';
                      if (n <= 0) return 'Debe ser > 0';
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            SwitchListTile(
              title: const Text('Marcar como favorita'),
              value: _favorita,
              onChanged: (v) => setState(() => _favorita = v),
              secondary: Icon(
                _favorita ? Icons.favorite : Icons.favorite_border,
                color: _favorita ? Colors.red : null,
              ),
            ),
            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save),
              label: Text(_esEdicion ? 'Guardar cambios' : 'Crear canción'),
              style: FilledButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}