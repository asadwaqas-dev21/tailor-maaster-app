import "package:equatable/equatable.dart";
import "package:tailor_app/core/enums/gender.dart";

class Customer extends Equatable {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final Gender gender;
  final String? notes;
  final DateTime createdAt;
  final String? imagePath;

  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    required this.gender,
    this.notes,
    required this.createdAt,
    this.imagePath,
  });

  Customer copyWith({
    String? id,
    String? name,
    String? phone,
    String? email,
    String? address,
    Gender? gender,
    String? notes,
    DateTime? createdAt,
    String? imagePath,
  }) {
    return Customer(
      id: id ?? this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      address: address ?? this.address,
      gender: gender ?? this.gender,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      imagePath: imagePath ?? this.imagePath,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, email, address, gender, notes, createdAt, imagePath];
}
