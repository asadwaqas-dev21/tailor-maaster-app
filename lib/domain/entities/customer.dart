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
  /// Regular / walking customer badge (Supabase: customers.is_regular)
  final bool isRegular;

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
    this.isRegular = false,
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
    bool? isRegular,
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
      isRegular: isRegular ?? this.isRegular,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        phone,
        email,
        address,
        gender,
        notes,
        createdAt,
        imagePath,
        isRegular,
      ];
}
