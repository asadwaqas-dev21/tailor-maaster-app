// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'staff_role.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class StaffRoleAdapter extends TypeAdapter<StaffRole> {
  @override
  final int typeId = 4;

  @override
  StaffRole read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return StaffRole.cutter;
      case 1:
        return StaffRole.stitcher;
      case 2:
        return StaffRole.finisher;
      case 3:
        return StaffRole.delivery;
      default:
        return StaffRole.cutter;
    }
  }

  @override
  void write(BinaryWriter writer, StaffRole obj) {
    switch (obj) {
      case StaffRole.cutter:
        writer.writeByte(0);
        break;
      case StaffRole.stitcher:
        writer.writeByte(1);
        break;
      case StaffRole.finisher:
        writer.writeByte(2);
        break;
      case StaffRole.delivery:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is StaffRoleAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
