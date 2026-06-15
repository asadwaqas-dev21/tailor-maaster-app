import "package:equatable/equatable.dart";
import "package:tailor_app/core/enums/gender.dart";

class Customer extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? address;
  final Gender gender;
  final String? notes;
  final DateTime createdAt;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.address,
    required this.gender,
    this.notes,
    required this.createdAt,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? address,
    Gender? gender,
    String? notes,
    DateTime? createdAt,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, address, gender, notes, createdAt];
}
