import 'package:flutter/material.dart';
import '../../models/order_model.dart';
import '../../supabase_config.dart';

class MyOrdersScreen extends StatefulWidget {
  const MyOrdersScreen({super.key});
  @override
  State<MyOrdersScreen> createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen> {
  late Future<List<OrderModel>> _future;

  @override
  void initState() {
    super.initState();
    _future = _cargar();
  }

  Future<List<OrderModel>> _cargar() async {
    final uid = supabase.auth.currentUser!.id;
    final data = await supabase
        .from('orders')
        .select('*, restaurants(name), order_items(*)')
        .eq('buyer_id', uid)
        .order('created_at', ascending: false);
    return (data as List)
        .map((e) => OrderModel.fromMap(Map<String, dynamic>.from(e)))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<OrderModel>>(
      future: _future,
      builder: (context, snap) {
        if (!snap.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        final lista = snap.data!;
        if (lista.isEmpty) {
          return const Center(child: Text('Aún no tienes pedidos.'));
        }
        return RefreshIndicator(
          onRefresh: () async => setState(() => _future = _cargar()),
          child: ListView.builder(
            itemCount: lista.length,
            itemBuilder: (_, i) {
              final o = lista[i];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                child: ListTile(
                  title: Text(o.restaurantName ?? 'Pizzería'),
                  subtitle: Text(
                    '${o.statusDisplay} · \$${o.totalAmount.toStringAsFixed(2)}\n${o.deliveryAddress}',
                  ),
                  isThreeLine: true,
                  trailing: o.status == 'pendiente'
                      ? IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          tooltip: 'Cancelar pedido',
                          onPressed: () async {
                            await supabase
                                .from('orders')
                                .update({'status': 'cancelado'}).eq('id', o.id);
                            setState(() => _future = _cargar());
                          },
                        )
                      : null,
                ),
              );
            },
          ),
        );
      },
    );
  }
}