import 'package:flutter/material.dart';
import '../../models/pizza_model.dart';
import '../../models/restaurant_model.dart';
import '../../supabase_config.dart';
import 'pizza_form_screen.dart';
import 'restaurant_form_screen.dart';
import 'order_detail_screen.dart';

class SellerHome extends StatefulWidget {
  const SellerHome({super.key});
  @override
  State<SellerHome> createState() => _SellerHomeState();
}

class _SellerHomeState extends State<SellerHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final tabs = [
      const _MiPizzeriaTab(),
      const _MisPizzasTab(),
      const _PedidosRecibidosTab(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pizzería · Vendedor'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await supabase.auth.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(context, '/login', (_) => false);
            },
          ),
        ],
      ),
      body: tabs[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.store), label: 'Mi pizzería'),
          NavigationDestination(icon: Icon(Icons.local_pizza), label: 'Pizzas'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Pedidos'),
        ],
      ),
    );
  }
}

// ---------- Mi pizzería (CRUD restaurante) ----------
class _MiPizzeriaTab extends StatefulWidget {
  const _MiPizzeriaTab();
  @override
  State<_MiPizzeriaTab> createState() => _MiPizzeriaTabState();
}

class _MiPizzeriaTabState extends State<_MiPizzeriaTab> {
  late Future<RestaurantModel?> _future;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<RestaurantModel?> _cargar() async {
    final uid = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('restaurants')
        .select()
        .eq('seller_id', uid)
        .maybeSingle();
    if (data == null) return null;
    return RestaurantModel.fromMap(Map<String, dynamic>.from(data));
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<RestaurantModel?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        final r = snap.data;
        if (r == null) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store_mall_directory,
                      size: 72, color: Colors.deepOrange),
                  const SizedBox(height: 16),
                  const Text('Aún no registras tu pizzería',
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    icon: const Icon(Icons.add),
                    label: const Text('Registrar pizzería'),
                    onPressed: () async {
                      final ok = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const RestaurantFormScreen()),
                      );
                      if (ok == true) setState(() => _future = _cargar());
                    },
                  ),
                ],
              ),
            ),
          );
        }
        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(r.name,
                        style: const TextStyle(
                            fontSize: 22, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    Text(r.description),
                    const SizedBox(height: 8),
                    Row(children: [
                      const Icon(Icons.location_on, size: 18),
                      const SizedBox(width: 4),
                      Expanded(child: Text(r.address)),
                    ]),
                    if (r.phone.isNotEmpty)
                      Row(children: [
                        const Icon(Icons.phone, size: 18),
                        const SizedBox(width: 4),
                        Text(r.phone),
                      ]),
                    Text(
                      'Coordenadas: ${r.latitude.toStringAsFixed(4)}, ${r.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(color: Colors.grey, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    icon: const Icon(Icons.edit),
                    label: const Text('Editar'),
                    onPressed: () async {
                      final ok = await Navigator.push<bool>(
                        context,
                        MaterialPageRoute(
                          builder: (_) => RestaurantFormScreen(restaurant: r),
                        ),
                      );
                      if (ok == true) setState(() => _future = _cargar());
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                    icon: const Icon(Icons.delete),
                    label: const Text('Eliminar'),
                    onPressed: () async {
                      final ok = await showDialog<bool>(
                        context: context,
                        builder: (_) => AlertDialog(
                          title: const Text('Eliminar pizzería'),
                          content: const Text(
                              'Se eliminarán también tus pizzas y pedidos. ¿Continuar?'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(context, false),
                              child: const Text('Cancelar'),
                            ),
                            FilledButton(
                              style: FilledButton.styleFrom(
                                  backgroundColor: Colors.red),
                              onPressed: () => Navigator.pop(context, true),
                              child: const Text('Eliminar'),
                            ),
                          ],
                        ),
                      );
                      if (ok != true) return;
                      await supabase
                          .from('restaurants')
                          .delete()
                          .eq('id', r.id);
                      if (!mounted) return;
                      setState(() => _future = _cargar());
                    },
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

// ---------- Mis pizzas ----------
class _MisPizzasTab extends StatefulWidget {
  const _MisPizzasTab();
  @override
  State<_MisPizzasTab> createState() => _MisPizzasTabState();
}

class _MisPizzasTabState extends State<_MisPizzasTab> {
  late Future<List<PizzaModel>> _future;
  RestaurantModel? _restaurante;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<List<PizzaModel>> _cargar() async {
    final uid = supabase.auth.currentUser!.id;
    final r = await supabase
        .from('restaurants')
        .select()
        .eq('seller_id', uid)
        .maybeSingle();
    if (r == null) {
      _restaurante = null;
      return [];
    }
    _restaurante = RestaurantModel.fromMap(Map<String, dynamic>.from(r));
    final data = await supabase
        .from('pizzas')
        .select()
        .eq('restaurant_id', _restaurante!.id)
        .order('name');
    return (data as List)
        .map((e) => PizzaModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<PizzaModel>>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        if (_restaurante == null) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text('Primero registra tu pizzería en la pestaña anterior.'),
            ),
          );
        }
        final lista = snap.data!;
        return Scaffold(
          body: lista.isEmpty
              ? const Center(child: Text('Aún no tienes pizzas.'))
              : ListView.builder(
                  itemCount: lista.length,
                  itemBuilder: (_, i) {
                    final p = lista[i];
                    return Card(
                      margin: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      child: ListTile(
                        title: Text(p.name),
                        subtitle: Text(
                          '\$${p.price.toStringAsFixed(2)} · ${p.isAvailable ? "Disponible" : "No disponible"}',
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () async {
                                final ok = await Navigator.push<bool>(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => PizzaFormScreen(
                                      restaurantId: _restaurante!.id,
                                      pizza: p,
                                    ),
                                  ),
                                );
                                if (ok == true) {
                                  setState(() => _future = _cargar());
                                }
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                await supabase
                                    .from('pizzas')
                                    .delete()
                                    .eq('id', p.id);
                                setState(() => _future = _cargar());
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
          floatingActionButton: FloatingActionButton(
            onPressed: () async {
              final ok = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => PizzaFormScreen(
                    restaurantId: _restaurante!.id,
                  ),
                ),
              );
              if (ok == true) setState(() => _future = _cargar());
            },
            child: const Icon(Icons.add),
          ),
        );
      },
    );
  }
}

// ---------- Pedidos recibidos ----------
class _PedidosRecibidosTab extends StatefulWidget {
  const _PedidosRecibidosTab();
  @override
  State<_PedidosRecibidosTab> createState() => _PedidosRecibidosTabState();
}

class _PedidosRecibidosTabState extends State<_PedidosRecibidosTab> {
  late Future<List<Map<String, dynamic>>> _future;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<List<Map<String, dynamic>>> _cargar() async {
    final uid = supabase.auth.currentUser!.id;

    // 1. Obtener restaurante del vendedor
    final r = await supabase
        .from('restaurants')
        .select('id')
        .eq('seller_id', uid)
        .maybeSingle();

    if (r == null) {
      debugPrint('Vendedor sin restaurante registrado');
      return [];
    }

    // 2. Traer pedidos de ese restaurante
    final data = await supabase
        .from('orders')
        .select(
          'id, status, total_amount, delivery_address, payment_method, '
          'notes, created_at, buyer_id, restaurant_id, '
          'profiles!orders_buyer_id_fkey(full_name, email), '
          'order_items(id, pizza_name, quantity, unit_price, size)',
        )
        .eq('restaurant_id', r['id'])
        .order('created_at', ascending: false);

    return List<Map<String, dynamic>>.from(data as List);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Map<String, dynamic>>>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState != ConnectionState.done) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 12),
                  Text('Error: ${snap.error}'),
                  const SizedBox(height: 12),
                  FilledButton(
                    onPressed: () => setState(() => _future = _cargar()),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            ),
          );
        }

        final lista = snap.data ?? [];
        if (lista.isEmpty) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(24),
              child: Text(
                'Aún no tienes pedidos.\nCuando un cliente compre, aparecerá aquí.',
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async => setState(() => _future = _cargar()),
          child: ListView.builder(
            itemCount: lista.length,
            itemBuilder: (_, i) {
              final o = lista[i];
              final perfil = o['profiles'] as Map<String, dynamic>?;
              final items = (o['order_items'] as List?) ?? [];

              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: _iconoEstado(o['status'] as String),
                  title: Text(
                    'Pedido #${o['id'].toString().substring(0, 8)}',
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Cliente: ${perfil?['full_name'] ?? "—"}'),
                      Text(
                        '${items.length} ítem(s) · \$${(o['total_amount'] as num).toStringAsFixed(2)}',
                      ),
                      Text(
                        _estadoTexto(o['status'] as String),
                        style: TextStyle(
                          color: _estadoColor(o['status'] as String),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () async {
                    final cambio = await Navigator.push<bool>(
                      context,
                      MaterialPageRoute(
                        builder: (_) => OrderDetailScreen(order: o),
                      ),
                    );
                    if (cambio == true) {
                      setState(() => _future = _cargar());
                    }
                  },
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _iconoEstado(String estado) {
    switch (estado) {
      case 'pendiente':
        return const CircleAvatar(
          backgroundColor: Colors.orange,
          child: Icon(Icons.hourglass_empty, color: Colors.white),
        );
      case 'en_preparacion':
        return const CircleAvatar(
          backgroundColor: Colors.blue,
          child: Icon(Icons.local_pizza, color: Colors.white),
        );
      case 'en_camino':
        return const CircleAvatar(
          backgroundColor: Colors.purple,
          child: Icon(Icons.delivery_dining, color: Colors.white),
        );
      case 'entregado':
        return const CircleAvatar(
          backgroundColor: Colors.green,
          child: Icon(Icons.check, color: Colors.white),
        );
      case 'cancelado':
        return const CircleAvatar(
          backgroundColor: Colors.red,
          child: Icon(Icons.cancel, color: Colors.white),
        );
      default:
        return const CircleAvatar(child: Icon(Icons.receipt));
    }
  }

  String _estadoTexto(String e) => const {
        'pendiente': 'Pendiente',
        'en_preparacion': 'En preparación',
        'en_camino': 'En camino',
        'entregado': 'Entregado',
        'cancelado': 'Cancelado',
      }[e] ??
      e;

  Color _estadoColor(String e) => const {
        'pendiente': Colors.orange,
        'en_preparacion': Colors.blue,
        'en_camino': Colors.purple,
        'entregado': Colors.green,
        'cancelado': Colors.red,
      }[e] ??
      Colors.grey;
}