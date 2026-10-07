import 'package:flutter/material.dart';
import '../../models/pizza_model.dart';
import '../../models/restaurant_model.dart';
import '../../supabase_config.dart';
import 'cart_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final RestaurantModel restaurant;
  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen> {
  late Future<List<PizzaModel>> _future;
  final List<Map<String, dynamic>> _carrito = [];

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<List<PizzaModel>> _cargar() async {
    final data = await supabase
        .from('pizzas')
        .select()
        .eq('restaurant_id', widget.restaurant.id)
        .eq('is_available', true);
    return (data as List)
        .map((e) => PizzaModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  void _agregar(PizzaModel p, String size) {
    setState(() {
      final i = _carrito.indexWhere(
          (e) => e['pizza']['id'] == p.id && e['size'] == size);
      if (i >= 0) {
        _carrito[i]['quantity']++;
      } else {
        _carrito.add({
          'pizza': {
            'id': p.id,
            'name': p.name,
            'price': p.price,
          },
          'quantity': 1,
          'size': size,
        });
      }
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${p.name} ($size) agregada')),
    );
  }

  Future<void> _elegirTamano(PizzaModel p) async {
    final size = await showModalBottomSheet<String>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Elige el tamaño',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ),
            for (final s in p.sizes)
              ListTile(
                title: Text(s),
                onTap: () => Navigator.pop(context, s),
              ),
          ],
        ),
      ),
    );
    if (size != null) _agregar(p, size);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(widget.restaurant.address,
                    style: const TextStyle(color: Colors.grey)),
                if (widget.restaurant.phone.isNotEmpty)
                  Text('Tel: ${widget.restaurant.phone}',
                      style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<PizzaModel>>(
              future: _future,
              builder: (context, snap) {
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final lista = snap.data!;
                if (lista.isEmpty) {
                  return const Center(child: Text('Sin pizzas disponibles.'));
                }
                return ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (_, i) {
                    final p = lista[i];
                    return Card(
                      margin:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      child: ListTile(
                        leading: p.imageUrl.isNotEmpty
                            ? Image.network(p.imageUrl,
                                width: 56,
                                height: 56,
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) =>
                                    const Icon(Icons.local_pizza, size: 40))
                            : const Icon(Icons.local_pizza, size: 40),
                        title: Text(p.name),
                        subtitle: Text(
                          '${p.description}\n\$${p.price.toStringAsFixed(2)}',
                        ),
                        isThreeLine: true,
                        trailing: FilledButton(
                          onPressed: () => _elegirTamano(p),
                          child: const Text('Agregar'),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: _carrito.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () async {
                final ok = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (_) => CartScreen(
                      restaurant: widget.restaurant,
                      items: _carrito,
                    ),
                  ),
                );
                if (ok == true) {
                  setState(() => _carrito.clear());
                  if (mounted) Navigator.pop(context);
                }
              },
              icon: const Icon(Icons.shopping_cart),
              label: Text(
                  'Ver carrito (${_carrito.fold<int>(0, (s, e) => s + (e['quantity'] as int))})'),
            ),
    );
  }
}