import 'package:flutter/material.dart';
import '../../models/pizza_model.dart';
import '../../models/restaurant_model.dart';
import '../../supabase_config.dart';
import '../login_screen.dart';
import 'restaurant_detail_screen.dart';
import 'my_orders_screen.dart';
import 'profile_screen.dart';

class BuyerHome extends StatefulWidget {
  const BuyerHome({super.key});
  @override
  State<BuyerHome> createState() => _BuyerHomeState();
}

class _BuyerHomeState extends State<BuyerHome> {
  int _tab = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      const _ExplorarTab(),
      const MyOrdersScreen(),
      const ProfileScreen(),
    ];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pizzería · Cliente'),
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
      body: pages[_tab],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tab,
        onDestinationSelected: (i) => setState(() => _tab = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.store), label: 'Explorar'),
          NavigationDestination(icon: Icon(Icons.receipt_long), label: 'Pedidos'),
          NavigationDestination(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _ExplorarTab extends StatefulWidget {
  const _ExplorarTab();
  @override
  State<_ExplorarTab> createState() => _ExplorarTabState();
}

class _ExplorarTabState extends State<_ExplorarTab> {
  late Future<List<RestaurantModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<List<RestaurantModel>> _cargar() async {
    final data = await supabase.from('restaurants').select().order('name');
    return (data as List)
        .map((e) => RestaurantModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<RestaurantModel>>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final lista = snap.data!;
        if (lista.isEmpty) {
          return const Center(child: Text('Aún no hay pizzerías registradas.'));
        }
        return RefreshIndicator(
          onRefresh: () async => setState(() => _future = _cargar()),
          child: ListView.builder(
            itemCount: lista.length,
            itemBuilder: (_, i) {
              final r = lista[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.deepOrange.shade100,
                    child: const Icon(Icons.local_pizza, color: Colors.deepOrange),
                  ),
                  title: Text(r.name),
                  subtitle: Text(r.address),
                  trailing: const Icon(Icons.chevron_right),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => RestaurantDetailScreen(restaurant: r),
                    ),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}