// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StaffModelAdapter extends TypeAdapter<StaffModel> {
  @override
  final int typeId = 3;

  @override
  StaffModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return StaffModel(
      id: fields[0] as String,
      name: fields[1] as String,
      phone: fields[2] as String,
      role: fields[3] as StaffRole,
      isActive: fields[4] as bool,
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, StaffModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phone)
      ..writeByte(3)
      ..write(obj.role)
      ..writeByte(4)
      ..write(obj.isActive)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
