import 'package:flutter/material.dart';
import '../../models/restaurant_model.dart';
import '../../supabase_config.dart';

class RestaurantFormScreen extends StatefulWidget {
  final RestaurantModel? restaurant;
  const RestaurantFormScreen({super.key, this.restaurant});

  @override
  State<RestaurantFormScreen> createState() => _RestaurantFormScreenState();
}

class _RestaurantFormScreenState extends State<RestaurantFormScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _desc = TextEditingController();
  final _direccion = TextEditingController();
  final _lat = TextEditingController();
  final _lng = TextEditingController();
  final _telefono = TextEditingController();
  final _imagen = TextEditingController();
  bool _guardando = false;

  bool get _esEdicion => widget.restaurant != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final r = widget.restaurant!;
      _nombre.text = r.name;
      _desc.text = r.description;
      _direccion.text = r.address;
      _lat.text = r.latitude.toString();
      _lng.text = r.longitude.toString();
      _telefono.text = r.phone;
      _imagen.text = r.imageUrl;
    }
  }

  @override
  void dispose() {
    for (final c in [_nombre, _desc, _direccion, _lat, _lng, _telefono, _imagen]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    setState(() => _guardando = true);
    try {
      final uid = supabase.auth.currentUser!.id;
      final data = {
        'seller_id': uid,
        'name': _nombre.text.trim(),
        'description': _desc.text.trim(),
        'address': _direccion.text.trim(),
        'latitude': double.parse(_lat.text.trim()),
        'longitude': double.parse(_lng.text.trim()),
        'phone': _telefono.text.trim(),
        'image_url': _imagen.text.trim(),
      };
      if (_esEdicion) {
        await supabase
            .from('restaurants')
            .update(data)
            .eq('id', widget.restaurant!.id);
      } else {
        await supabase.from('restaurants').insert(data);
      }
      if (!mounted) return;
      Navigator.pop(context, true);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(_esEdicion ? 'Editar pizzería' : 'Registrar pizzería'),
      ),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _campo(_nombre, 'Nombre *', Icons.store),
            _campo(_desc, 'Descripción', Icons.description),
            _campo(_direccion, 'Dirección *', Icons.location_on),
            Row(children: [
              Expanded(
                child: _campo(_lat, 'Latitud *', Icons.map,
                    tipo: TextInputType.number),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _campo(_lng, 'Longitud *', Icons.map,
                    tipo: TextInputType.number),
              ),
            ]),
            _campo(_telefono, 'Teléfono', Icons.phone),
            _campo(_imagen, 'URL de imagen', Icons.image),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(_esEdicion ? 'Guardar cambios' : 'Registrar'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _campo(
    TextEditingController c,
    String label,
    IconData icon, {
    TextInputType? tipo,
  }) {
    final esRequerido = label.contains('*');
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: c,
        keyboardType: tipo,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          prefixIcon: Icon(icon),
        ),
        validator: esRequerido
            ? (v) => (v == null || v.trim().isEmpty) ? 'Requerido' : null
            : null,
      ),
    );
  }
}