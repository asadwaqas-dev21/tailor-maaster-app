import "package:hive/hive.dart";
import "package:tailor_app/core/enums/gender.dart";
import "package:tailor_app/domain/entities/customer.dart";

part "customer_model.g.dart";

@HiveType(typeId: 0)
class CustomerModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String phone;

  @HiveField(3)
  final String? address;

  @HiveField(4)
  final Gender gender;

  @HiveField(5)
  final String? notes;

  @HiveField(6)
  final DateTime createdAt;

  @HiveField(7)
  final String? email;

  @HiveField(8)
  final String? imagePath;

  CustomerModel({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    required this.gender,
    this.notes,
    required this.createdAt,
    this.email,
    this.imagePath,
  });

  /// Convert to domain entity
  Customer toEntity() {
    return Customer(
      id: id,
      name: name,
      phone: phone,
      email: email,
      address: address,
      gender: gender,
      notes: notes,
      createdAt: createdAt,
      imagePath: imagePath,
    );
  }

  /// Create from domain entity
  factory CustomerModel.fromEntity(Customer entity) {
    return CustomerModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      address: entity.address,
      gender: entity.gender,
      notes: entity.notes,
      createdAt: entity.createdAt,
      imagePath: entity.imagePath,
    );
  }
}
