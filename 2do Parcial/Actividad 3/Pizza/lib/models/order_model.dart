class OrderItemModel {
  final String? id;
  final String? orderId;
  final String? pizzaId;
  final String pizzaName;
  final int quantity;
  final double unitPrice;
  final String size;

  const OrderItemModel({
    this.id,
    this.orderId,
    this.pizzaId,
    required this.pizzaName,
    required this.quantity,
    required this.unitPrice,
    this.size = 'Mediana',
  });

  double get totalPrice => unitPrice * quantity;

  factory OrderItemModel.fromMap(Map<String, dynamic> m) => OrderItemModel(
        id: m['id']?.toString(),
        orderId: m['order_id']?.toString(),
        pizzaId: m['pizza_id']?.toString(),
        pizzaName: m['pizza_name'] as String? ?? '',
        quantity: (m['quantity'] as num?)?.toInt() ?? 1,
        unitPrice: (m['unit_price'] as num?)?.toDouble() ?? 0,
        size: m['size'] as String? ?? 'Mediana',
      );

  Map<String, dynamic> toMap() => {
        'pizza_id': pizzaId,
        'pizza_name': pizzaName,
        'quantity': quantity,
        'unit_price': unitPrice,
        'size': size,
      };
}

class OrderModel {
  final String id;
  final String buyerId;
  final String restaurantId;
  final String? restaurantName;
  final String? buyerName;
  final String? buyerEmail;
  final String status;
  final double totalAmount;
  final String deliveryAddress;
  final String paymentMethod;
  final String? notes;
  final DateTime createdAt;
  final List<OrderItemModel> items;

  const OrderModel({
    required this.id,
    required this.buyerId,
    required this.restaurantId,
    this.restaurantName,
    this.buyerName,
    this.buyerEmail,
    this.status = 'pendiente',
    required this.totalAmount,
    required this.deliveryAddress,
    this.paymentMethod = 'Efectivo',
    this.notes,
    required this.createdAt,
    this.items = const [],
  });

  String get statusDisplay {
    switch (status) {
      case 'pendiente':
        return 'Pendiente';
      case 'en_preparacion':
        return 'En Preparación';
      case 'en_camino':
        return 'En Camino';
      case 'entregado':
        return 'Entregado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return status;
    }
  }

  factory OrderModel.fromMap(Map<String, dynamic> m) {
    final itemsJson = m['order_items'] as List?;
    return OrderModel(
      id: m['id'].toString(),
      buyerId: m['buyer_id'] as String,
      restaurantId: m['restaurant_id'].toString(),
      restaurantName: (m['restaurants'] as Map?)?['name'] as String?,
      buyerName: (m['profiles'] as Map?)?['full_name'] as String?,
      buyerEmail: (m['profiles'] as Map?)?['email'] as String?,
      status: m['status'] as String? ?? 'pendiente',
      totalAmount: (m['total_amount'] as num?)?.toDouble() ?? 0,
      deliveryAddress: m['delivery_address'] as String? ?? '',
      paymentMethod: m['payment_method'] as String? ?? 'Efectivo',
      notes: m['notes'] as String?,
      createdAt:
          DateTime.tryParse(m['created_at']?.toString() ?? '') ?? DateTime.now(),
      items: itemsJson
              ?.map((e) => OrderItemModel.fromMap(Map<String, dynamic>.from(e)))
              .toList() ??
          const [],
    );
  }
}