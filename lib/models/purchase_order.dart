import 'package:hive/hive.dart';

part 'purchase_order.g.dart';

@HiveType(typeId: 4)
enum PurchaseOrderStatus {
  @HiveField(0)
  pending,    // Pedido realizado, esperando envío
  @HiveField(1)
  shipped,    // En tránsito
  @HiveField(2)
  received,   // Recibido en almacén
  @HiveField(3)
  cancelled,  // Cancelado
}

@HiveType(typeId: 5)
class PurchaseOrderItem {
  @HiveField(0)
  final String sku;
  @HiveField(1)
  final String name;
  @HiveField(2)
  final int quantity;
  @HiveField(3)
  final double costUsd;
  @HiveField(4)
  final double total;

  PurchaseOrderItem({
    required this.sku,
    required this.name,
    required this.quantity,
    required this.costUsd,
    required this.total,
  });

  Map<String, dynamic> toMap() {
    return {
      'sku': sku,
      'name': name,
      'quantity': quantity,
      'costUsd': costUsd,
      'total': total,
    };
  }

  factory PurchaseOrderItem.fromMap(Map<String, dynamic> map) {
    return PurchaseOrderItem(
      sku: map['sku'],
      name: map['name'],
      quantity: map['quantity'],
      costUsd: (map['costUsd'] ?? 0).toDouble(),
      total: (map['total'] ?? 0).toDouble(),
    );
  }
}

@HiveType(typeId: 6)
class PurchaseOrder {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String supplierId;
  @HiveField(2)
  final String supplierName;
  @HiveField(3)
  final DateTime date;
  @HiveField(4)
  final DateTime? expectedArrival;
  @HiveField(5)
  final List<PurchaseOrderItem> items;
  @HiveField(6)
  final double totalUsd;
  @HiveField(7)
  final PurchaseOrderStatus status;
  @HiveField(8)
  final String? trackingNumber;
  @HiveField(9)
  final String? notes;

  PurchaseOrder({
    required this.id,
    required this.supplierId,
    required this.supplierName,
    required this.date,
    this.expectedArrival,
    required this.items,
    required this.totalUsd,
    required this.status,
    this.trackingNumber,
    this.notes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'supplierId': supplierId,
      'supplierName': supplierName,
      'date': date.toIso8601String(),
      'expectedArrival': expectedArrival?.toIso8601String(),
      'items': items.map((i) => i.toMap()).toList(),
      'totalUsd': totalUsd,
      'status': status.name,
      'trackingNumber': trackingNumber,
      'notes': notes,
    };
  }

  factory PurchaseOrder.fromMap(Map<String, dynamic> map) {
    return PurchaseOrder(
      id: map['id'],
      supplierId: map['supplierId'],
      supplierName: map['supplierName'],
      date: DateTime.parse(map['date']),
      expectedArrival: map['expectedArrival'] != null ? DateTime.parse(map['expectedArrival']) : null,
      items: (map['items'] as List).map((i) => PurchaseOrderItem.fromMap(i)).toList(),
      totalUsd: (map['totalUsd'] ?? 0).toDouble(),
      status: PurchaseOrderStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PurchaseOrderStatus.pending,
      ),
      trackingNumber: map['trackingNumber'],
      notes: map['notes'],
    );
  }

  PurchaseOrder copyWith({
    String? id,
    String? supplierId,
    String? supplierName,
    DateTime? date,
    DateTime? expectedArrival,
    List<PurchaseOrderItem>? items,
    double? totalUsd,
    PurchaseOrderStatus? status,
    String? trackingNumber,
    String? notes,
  }) {
    return PurchaseOrder(
      id: id ?? this.id,
      supplierId: supplierId ?? this.supplierId,
      supplierName: supplierName ?? this.supplierName,
      date: date ?? this.date,
      expectedArrival: expectedArrival ?? this.expectedArrival,
      items: items ?? this.items,
      totalUsd: totalUsd ?? this.totalUsd,
      status: status ?? this.status,
      trackingNumber: trackingNumber ?? this.trackingNumber,
      notes: notes ?? this.notes,
    );
  }
}
