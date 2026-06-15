// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'measurement_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MeasurementModelAdapter extends TypeAdapter<MeasurementModel> {
  @override
  final int typeId = 2;

  @override
  MeasurementModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MeasurementModel(
      id: fields[0] as String,
      customerId: fields[1] as String,
      category: fields[2] as String,
      fields: (fields[3] as Map).cast<String, double>(),
      photoPaths: (fields[4] as List).cast<String>(),
      createdAt: fields[5] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, MeasurementModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.customerId)
      ..writeByte(2)
      ..write(obj.category)
      ..writeByte(3)
      ..write(obj.fields)
      ..writeByte(4)
      ..write(obj.photoPaths)
      ..writeByte(5)
      ..write(obj.createdAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MeasurementModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
