import "package:equatable/equatable.dart";
import "package:tailor_app/core/enums/staff_role.dart";

class Staff extends Equatable {
  final String id;
  final String name;
  final String phone;
  final StaffRole role;
  final bool isActive;
  final DateTime createdAt;
  final String? imagePath;

  const Staff({
    required this.id,
    required this.name,
    required this.phone,
    required this.role,
    this.isActive = true,
    required this.createdAt,
    this.imagePath,
  });

  Staff copyWith({
    String? id,
    String? name,
    String? phone,
    StaffRole? role,
    bool? isActive,
    DateTime? createdAt,
    String? imagePath,
  }) {
    return Staff(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, role, isActive, createdAt, imagePath];
}
