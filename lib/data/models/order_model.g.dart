// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'order_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class OrderModelAdapter extends TypeAdapter<OrderModel> {
  @override
  final int typeId = 1;

  @override
  OrderModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return OrderModel(
      id: fields[0] as String,
      customerId: fields[1] as String,
      customerName: fields[2] as String,
      measurementId: fields[3] as String?,
      garmentType: fields[4] as String,
      fabricDetails: fields[5] as String?,
      designNotes: fields[6] as String?,
      quantity: fields[7] as int,
      totalAmount: fields[8] as double,
      advanceAmount: fields[9] as double,
      status: fields[10] as OrderStatus,
      paymentStatus: fields[11] as PaymentStatus,
      orderDate: fields[12] as DateTime,
      deliveryDate: fields[13] as DateTime,
      photoPaths: (fields[14] as List).cast<String>(),
      createdAt: fields[15] as DateTime,
      assignedStaffId: fields[16] as String?,
      assignedStaffName: fields[17] as String?,
      stitchingCost: fields[18] as double?,
      isStitcherPaid: fields[19] as bool?,
    );
  }

  @override
  void write(BinaryWriter writer, OrderModel obj) {
    writer
      ..writeByte(20)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.customerName)
      ..writeByte(3)
      ..write(obj.measurementId)
      ..writeByte(4)
      ..write(obj.garmentType)
      ..writeByte(5)
      ..write(obj.fabricDetails)
      ..writeByte(6)
      ..write(obj.designNotes)
      ..writeByte(7)
      ..write(obj.quantity)
      ..writeByte(8)
      ..write(obj.totalAmount)
      ..writeByte(9)
      ..write(obj.advanceAmount)
      ..writeByte(10)
      ..write(obj.status)
      ..writeByte(11)
      ..write(obj.paymentStatus)
      ..writeByte(12)
      ..write(obj.orderDate)
      ..writeByte(13)
      ..write(obj.deliveryDate)
      ..writeByte(14)
      ..write(obj.photoPaths)
      ..writeByte(15)
      ..write(obj.createdAt)
      ..writeByte(16)
      ..write(obj.assignedStaffId)
      ..writeByte(17)
      ..write(obj.assignedStaffName)
      ..writeByte(18)
      ..write(obj.stitchingCost)
      ..writeByte(19)
      ..write(obj.isStitcherPaid);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is OrderModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
