import "package:equatable/equatable.dart";
import "package:tailor_app/core/enums/staff_role.dart";

class Staff extends Equatable {
  final String id;
  final String name;
  final String phone;
  final StaffRole role;
  final bool isActive;
  final DateTime createdAt;

  const Staff({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.isActive = true,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [id, name, phone, role, isActive, createdAt];
}
