import 'package:flutter/material.dart';
import '../../models/pizza_model.dart';
import '../../supabase_config.dart';

class PizzaFormScreen extends StatefulWidget {
  final String restaurantId;
  final PizzaModel? pizza;
  const PizzaFormScreen({super.key, required this.restaurantId, this.pizza});

  @override
  State<PizzaFormScreen> createState() => _PizzaFormScreenState();
}

class _PizzaFormScreenState extends State<PizzaFormScreen> {
  final _form = GlobalKey<FormState>();
  final _nombre = TextEditingController();
  final _desc = TextEditingController();
  final _precio = TextEditingController();
  final _imagen = TextEditingController();
  final _categoria = TextEditingController(text: 'Clasicas');
  bool _disponible = true;
  bool _guardando = false;
  final Set<String> _tamanos = {'Personal', 'Mediana', 'Familiar'};

  bool get _esEdicion => widget.pizza != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final p = widget.pizza!;
      _nombre.text = p.name;
      _desc.text = p.description;
      _precio.text = p.price.toString();
      _imagen.text = p.imageUrl;
      _categoria.text = p.category;
      _disponible = p.isAvailable;
      _tamanos
        ..clear()
        ..addAll(p.sizes);
    }
  }

  @override
  void dispose() {
    for (final c in [_nombre, _desc, _precio, _imagen, _categoria]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _guardar() async {
    if (!_form.currentState!.validate()) return;
    if (_tamanos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Selecciona al menos un tamaño')),
      );
      return;
    }
    setState(() => _guardando = true);
    try {
      final data = {
        'restaurant_id': widget.restaurantId,
        'name': _nombre.text.trim(),
        'description': _desc.text.trim(),
        'price': double.parse(_precio.text.trim()),
        'image_url': _imagen.text.trim(),
        'sizes': _tamanos.toList(),
        'category': _categoria.text.trim(),
        'is_available': _disponible,
      };
      if (_esEdicion) {
        await supabase.from('pizzas').update(data).eq('id', widget.pizza!.id);
      } else {
        await supabase.from('pizzas').insert(data);
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
      appBar: AppBar(title: Text(_esEdicion ? 'Editar pizza' : 'Nueva pizza')),
      body: Form(
        key: _form,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _nombre,
              decoration: const InputDecoration(
                labelText: 'Nombre *',
                border: OutlineInputBorder(),
              ),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Requerido' : null,
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _desc,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _precio,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Precio *',
                border: OutlineInputBorder(),
                prefixText: '\$ ',
              ),
              validator: (v) {
                final n = double.tryParse(v ?? '');
                if (n == null || n <= 0) return 'Precio inválido';
                return null;
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _imagen,
              decoration: const InputDecoration(
                labelText: 'URL de imagen',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _categoria,
              decoration: const InputDecoration(
                labelText: 'Categoría',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 12),
            const Text('Tamaños disponibles:'),
            Wrap(
              spacing: 8,
              children: ['Personal', 'Mediana', 'Familiar']
                  .map(
                    (s) => FilterChip(
                      label: Text(s),
                      selected: _tamanos.contains(s),
                      onSelected: (v) => setState(() {
                        if (v) {
                          _tamanos.add(s);
                        } else {
                          _tamanos.remove(s);
                        }
                      }),
                    ),
                  )
                  .toList(),
            ),
            SwitchListTile(
              title: const Text('Disponible'),
              value: _disponible,
              onChanged: (v) => setState(() => _disponible = v),
            ),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: _guardando ? null : _guardar,
              icon: _guardando
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.save),
              label: Text(_esEdicion ? 'Guardar cambios' : 'Crear pizza'),
            ),
          ],
        ),
      ),
    );
  }
}