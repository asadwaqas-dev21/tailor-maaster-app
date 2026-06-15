import "package:equatable/equatable.dart";

class Measurement extends Equatable {
  final String id;
  final String customerId;
  final String category;
  final Map<String, double> fields;
  final List<String> photoPaths;
  final DateTime createdAt;

  const Measurement({
    required this.id,
    required this.customerId,
    required this.category,
    required this.fields,
    this.photoPaths = const [],
    required this.createdAt,
  });

  Measurement copyWith({
    String? id,
    String? customerId,
    String? category,
    Map<String, double>? fields,
    List<String>? photoPaths,
    DateTime? createdAt,
  }) {
    return Measurement(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      category: category ?? this.category,
      fields: fields ?? this.fields,
      photoPaths: photoPaths ?? this.photoPaths,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [id, customerId, category, fields, photoPaths, createdAt];
}
