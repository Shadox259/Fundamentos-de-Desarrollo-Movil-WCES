import 'package:flutter/material.dart';
import '../../supabase_config.dart';

class OrderDetailScreen extends StatefulWidget {
  /// Mapa crudo del pedido tal como lo devuelve Supabase.
  final Map<String, dynamic> order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late String _estado;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _estado = widget.order['status'] as String? ?? 'pendiente';
  }

  Future<void> _cambiarEstado(String nuevo) async {
    setState(() => _guardando = true);
    try {
      await supabase
          .from('orders')
          .update({'status': nuevo})
          .eq('id', widget.order['id']);
      if (!mounted) return;
      setState(() => _estado = nuevo);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Estado actualizado a "${_estadoTexto(nuevo)}"')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _guardando = false);
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

  @override
  Widget build(BuildContext context) {
    final o = widget.order;
    final perfil = o['profiles'] as Map<String, dynamic>?;
    final items = (o['order_items'] as List?) ?? [];
    final total = (o['total_amount'] as num?)?.toDouble() ?? 0;
    final fecha = DateTime.tryParse(o['created_at']?.toString() ?? '');
    final idCorto = o['id'].toString().substring(0, 8);

    return Scaffold(
      appBar: AppBar(
        title: Text('Pedido #$idCorto'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Estado actual
          Card(
            color: _estadoColor(_estado).withOpacity(0.1),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(Icons.circle, color: _estadoColor(_estado), size: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Estado: ${_estadoTexto(_estado)}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: _estadoColor(_estado),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Datos del cliente
          const _TituloSeccion('Cliente'),
          Card(
            child: ListTile(
              leading: const Icon(Icons.person),
              title: Text(perfil?['full_name'] ?? 'Sin nombre'),
              subtitle: Text(perfil?['email'] ?? ''),
            ),
          ),
          const SizedBox(height: 16),

          // Datos de entrega
          const _TituloSeccion('Entrega'),
          Card(
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text('Dirección'),
                  subtitle: Text(o['delivery_address']?.toString() ?? '—'),
                ),
                const Divider(height: 1),
                ListTile(
                  leading: const Icon(Icons.payment),
                  title: const Text('Método de pago'),
                  subtitle: Text(o['payment_method']?.toString() ?? '—'),
                ),
                if ((o['notes'] ?? '').toString().isNotEmpty) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.note),
                    title: const Text('Notas'),
                    subtitle: Text(o['notes'].toString()),
                  ),
                ],
                if (fecha != null) ...[
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.access_time),
                    title: const Text('Fecha'),
                    subtitle: Text(
                      '${fecha.day}/${fecha.month}/${fecha.year} '
                      '${fecha.hour.toString().padLeft(2, '0')}:'
                      '${fecha.minute.toString().padLeft(2, '0')}',
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Ítems
          const _TituloSeccion('Productos'),
          Card(
            child: Column(
              children: [
                for (final it in items)
                  ListTile(
                    dense: true,
                    leading: CircleAvatar(
                      backgroundColor: Colors.deepOrange.shade100,
                      child: Text('${it['quantity']}x'),
                    ),
                    title: Text(it['pizza_name']?.toString() ?? ''),
                    subtitle: Text('Tamaño: ${it['size'] ?? '—'}'),
                    trailing: Text(
                      '\$${((it['unit_price'] as num) * (it['quantity'] as num)).toStringAsFixed(2)}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                const Divider(height: 1),
                ListTile(
                  title: const Text(
                    'Total',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  trailing: Text(
                    '\$${total.toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Cambiar estado
          const _TituloSeccion('Cambiar estado'),
          if (_estado == 'entregado' || _estado == 'cancelado')
            Card(
              child: ListTile(
                leading: const Icon(Icons.lock, color: Colors.grey),
                title: Text(
                  'El pedido ya está ${_estadoTexto(_estado).toLowerCase()}.',
                ),
                subtitle: const Text('No se puede modificar más.'),
              ),
            )
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (_estado == 'pendiente')
                  FilledButton.icon(
                    onPressed: _guardando
                        ? null
                        : () => _cambiarEstado('en_preparacion'),
                    icon: const Icon(Icons.local_pizza),
                    label: const Text('Aceptar y preparar'),
                  ),
                if (_estado == 'en_preparacion')
                  FilledButton.icon(
                    onPressed:
                        _guardando ? null : () => _cambiarEstado('en_camino'),
                    icon: const Icon(Icons.delivery_dining),
                    label: const Text('Marcar en camino'),
                  ),
                if (_estado == 'en_camino')
                  FilledButton.icon(
                    onPressed:
                        _guardando ? null : () => _cambiarEstado('entregado'),
                    icon: const Icon(Icons.check),
                    label: const Text('Marcar entregado'),
                  ),
                if (_estado != 'cancelado')
                  OutlinedButton.icon(
                    onPressed:
                        _guardando ? null : () => _confirmarCancelar(),
                    icon: const Icon(Icons.cancel, color: Colors.red),
                    label: const Text(
                      'Cancelar pedido',
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
              ],
            ),
        ],
      ),
    );
  }

  Future<void> _confirmarCancelar() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cancelar pedido'),
        content: const Text(
            'Esta acción no se puede deshacer. ¿Cancelar el pedido?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('No'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Sí, cancelar'),
          ),
        ],
      ),
    );
    if (ok == true) _cambiarEstado('cancelado');
  }
}

class _TituloSeccion extends StatelessWidget {
  final String texto;
  const _TituloSeccion(this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, top: 8),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.grey,
        ),
      ),
    );
  }
}