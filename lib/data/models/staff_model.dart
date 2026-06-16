import "package:hive/hive.dart";
import "package:tailor_app/core/enums/staff_role.dart";
import "package:tailor_app/domain/entities/staff.dart";

part "staff_model.g.dart";

@HiveType(typeId: 3)
class StaffModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String name;

  @HiveField(2)
  String phone;

  @HiveField(3)
  StaffRole role;

  @HiveField(4)
  bool isActive;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  String? imagePath;

  StaffModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    required this.isActive,
    required this.createdAt,
    this.imagePath,
  });

  factory StaffModel.fromEntity(Staff staff) {
    return StaffModel(
      id: staff.id,
      name: staff.name,
      phone: staff.phone,
      role: staff.role,
      isActive: staff.isActive,
      createdAt: staff.createdAt,
      imagePath: staff.imagePath,
    );
  }

  Staff toEntity() {
    return Staff(
      id: id,
      name: name,
      phone: phone,
      role: role,
      isActive: isActive,
      createdAt: createdAt,
      imagePath: imagePath,
    );
  }
}
