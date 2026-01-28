enum OrderStatus {
  quote,      // Cotización (Lead)
  pending,    // Confirmado, esperando pago/preparación
  ready,      // Listo para entrega/envío
  completed,  // Entregado y cerrado
  cancelled,  // Cancelado
}

class OrderItem {
  final String sku;
  final String name;
  final int quantity;
  final double price;
  final double total;

  OrderItem({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.price,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'sku': sku,
      'name': name,
      'quantity': quantity,
      'price': price,
      'total': total,
    };
  }

  factory OrderItem.fromMap(Map<String, dynamic> map) {
    return OrderItem(
      sku: map['sku'],
      name: map['name'],
      quantity: map['quantity'],
      price: (map['price'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
    );
  }
}

class Order {
  final String id;
  final String customerName;
  final DateTime date;
  final List<OrderItem> items;
  final double total;
  final OrderStatus status;
  final String? paymentMethod;
  final DateTime? paymentDate;
  final DateTime? deliveryDate;

  Order({
    required this.id,
    required this.customerName,
    required this.date,
    required this.items,
    required this.total,
    required this.status,
    this.paymentMethod,
    this.paymentDate,
    this.deliveryDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customerName': customerName,
      'date': date.toIso8601String(),
      'items': items.map((i) => i.toMap()).toList(),
      'total': total,
      'status': status.name,
      'paymentMethod': paymentMethod,
      'paymentDate': paymentDate?.toIso8601String(),
      'deliveryDate': deliveryDate?.toIso8601String(),
    };
  }

  factory Order.fromMap(Map<String, dynamic> map) {
    return Order(
      id: map['id'],
      customerName: map['customerName'],
      date: DateTime.parse(map['date']),
      items: (map['items'] as List).map((i) => OrderItem.fromMap(i)).toList(),
      total: (map['total'] ?? 0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => OrderStatus.quote,
      ),
      paymentMethod: map['paymentMethod'],
      paymentDate: map['paymentDate'] != null ? DateTime.parse(map['paymentDate']) : null,
      deliveryDate: map['deliveryDate'] != null ? DateTime.parse(map['deliveryDate']) : null,
    );
  }

  Order copyWith({
    String? id,
    String? customerName,
    DateTime? date,
    List<OrderItem>? items,
    double? total,
    OrderStatus? status,
    String? paymentMethod,
    DateTime? paymentDate,
    DateTime? deliveryDate,
  }) {
    return Order(
      id: id ?? this.id,
      customerName: customerName ?? this.customerName,
      date: date ?? this.date,
      items: items ?? this.items,
      total: total ?? this.total,
      status: status ?? this.status,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentDate: paymentDate ?? this.paymentDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
    );
  }

  String get statusLabel {
    switch (status) {
      case OrderStatus.quote:
        return 'Cotización';
      case OrderStatus.pending:
        return 'Pendiente';
      case OrderStatus.ready:
        return 'Listo Entrega';
      case OrderStatus.completed:
        return 'Completado';
      case OrderStatus.cancelled:
        return 'Cancelado';
    }
  }
}
