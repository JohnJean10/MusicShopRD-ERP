// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'purchase_order.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PurchaseOrderItemAdapter extends TypeAdapter<PurchaseOrderItem> {
  @override
  final int typeId = 5;

  @override
  PurchaseOrderItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchaseOrderItem(
      sku: fields[0] as String,
      name: fields[1] as String,
      quantity: fields[2] as int,
      costUsd: fields[3] as double,
      total: fields[4] as double,
    );
  }

  @override
  void write(BinaryWriter writer, PurchaseOrderItem obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.sku)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.quantity)
      ..writeByte(3)
      ..write(obj.costUsd)
      ..writeByte(4)
      ..write(obj.total);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseOrderItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PurchaseOrderAdapter extends TypeAdapter<PurchaseOrder> {
  @override
  final int typeId = 6;

  @override
  PurchaseOrder read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PurchaseOrder(
      id: fields[0] as String,
      supplierId: fields[1] as String,
      supplierName: fields[2] as String,
      date: fields[3] as DateTime,
      expectedArrival: fields[4] as DateTime?,
      items: (fields[5] as List).cast<PurchaseOrderItem>(),
      totalUsd: fields[6] as double,
      status: fields[7] as PurchaseOrderStatus,
      trackingNumber: fields[8] as String?,
      notes: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PurchaseOrder obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.supplierId)
      ..writeByte(2)
      ..write(obj.supplierName)
      ..writeByte(3)
      ..write(obj.date)
      ..writeByte(4)
      ..write(obj.expectedArrival)
      ..writeByte(5)
      ..write(obj.items)
      ..writeByte(6)
      ..write(obj.totalUsd)
      ..writeByte(7)
      ..write(obj.status)
      ..writeByte(8)
      ..write(obj.trackingNumber)
      ..writeByte(9)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseOrderAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class PurchaseOrderStatusAdapter extends TypeAdapter<PurchaseOrderStatus> {
  @override
  final int typeId = 4;

  @override
  PurchaseOrderStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return PurchaseOrderStatus.pending;
      case 1:
        return PurchaseOrderStatus.shipped;
      case 2:
        return PurchaseOrderStatus.received;
      case 3:
        return PurchaseOrderStatus.cancelled;
      default:
        return PurchaseOrderStatus.pending;
    }
  }

  @override
  void write(BinaryWriter writer, PurchaseOrderStatus obj) {
    switch (obj) {
      case PurchaseOrderStatus.pending:
        writer.writeByte(0);
        break;
      case PurchaseOrderStatus.shipped:
        writer.writeByte(1);
        break;
      case PurchaseOrderStatus.received:
        writer.writeByte(2);
        break;
      case PurchaseOrderStatus.cancelled:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PurchaseOrderStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
