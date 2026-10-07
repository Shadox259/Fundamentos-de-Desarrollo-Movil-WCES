import 'package:flutter/material.dart';
import '../../models/restaurant_model.dart';
import '../../supabase_config.dart';

class CartScreen extends StatefulWidget {
  final RestaurantModel restaurant;
  final List<Map<String, dynamic>> items;

  const CartScreen({
    super.key,
    required this.restaurant,
    required this.items,
  });

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  final _direccion = TextEditingController();
  final _notas = TextEditingController();
  String _pago = 'Efectivo';
  bool _enviando = false;

  double get _total => widget.items.fold(
        0,
        (s, e) =>
            s +
            ((e['pizza']['price'] as num).toDouble() *
                (e['quantity'] as int)),
      );

  Future<void> _confirmar() async {
    if (_direccion.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ingresa la dirección de entrega')),
      );
      return;
    }
    setState(() => _enviando = true);
    try {
      final user = supabase.auth.currentUser!;
      final pedido = await supabase
          .from('orders')
          .insert({
            'buyer_id': user.id,
            'restaurant_id': widget.restaurant.id,
            'total_amount': _total,
            'delivery_address': _direccion.text.trim(),
            'payment_method': _pago,
            'notes': _notas.text.trim().isEmpty ? null : _notas.text.trim(),
            'status': 'pendiente',
          })
          .select()
          .single();

      for (final it in widget.items) {
        await supabase.from('order_items').insert({
          'order_id': pedido['id'],
          'pizza_id': it['pizza']['id'],
          'pizza_name': it['pizza']['name'],
          'quantity': it['quantity'],
          'unit_price': it['pizza']['price'],
          'size': it['size'],
        });
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('¡Pedido enviado!')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Carrito')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final it in widget.items)
            ListTile(
              title: Text('${it['pizza']['name']} (${it['size']})'),
              subtitle: Text(
                  '\$${(it['pizza']['price'] as num).toStringAsFixed(2)} c/u'),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.remove),
                    onPressed: () => setState(() {
                      it['quantity'] = (it['quantity'] as int) - 1;
                      if ((it['quantity'] as int) <= 0) {
                        widget.items.remove(it);
                      }
                    }),
                  ),
                  Text('${it['quantity']}'),
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () => setState(() => it['quantity']++),
                  ),
                ],
              ),
            ),
          const Divider(),
          Text('Total: \$${_total.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          TextField(
            controller: _direccion,
            decoration: const InputDecoration(
              labelText: 'Dirección de entrega *',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            value: _pago,
            decoration: const InputDecoration(
              labelText: 'Método de pago',
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'Efectivo', child: Text('Efectivo')),
              DropdownMenuItem(value: 'Tarjeta', child: Text('Tarjeta')),
              DropdownMenuItem(value: 'Transferencia', child: Text('Transferencia')),
            ],
            onChanged: (v) => setState(() => _pago = v ?? 'Efectivo'),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _notas,
            decoration: const InputDecoration(
              labelText: 'Notas (opcional)',
              border: OutlineInputBorder(),
            ),
            maxLines: 2,
          ),
          const SizedBox(height: 20),
          FilledButton.icon(
            onPressed: _enviando ? null : _confirmar,
            icon: _enviando
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2))
                : const Icon(Icons.check),
            label: const Text('Confirmar pedido'),
          ),
        ],
      ),
    );
  }
}