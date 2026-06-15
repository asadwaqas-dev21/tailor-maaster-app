import "package:hive/hive.dart";
import "package:tailor_app/domain/entities/measurement.dart";

part "measurement_model.g.dart";

@HiveType(typeId: 2)
class MeasurementModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerId;

  @HiveField(2)
  final String category;

  @HiveField(3)
  final Map<String, double> fields;

  @HiveField(4)
  final List<String> photoPaths;

  @HiveField(5)
  final DateTime createdAt;

  MeasurementModel({
    required this.id,
    required this.customerId,
    required this.category,
    required this.fields,
    this.photoPaths = const [],
    required this.createdAt,
  });

  /// Convert to domain entity
  Measurement toEntity() {
    return Measurement(
      id: id,
      customerId: customerId,
      category: category,
      fields: Map<String, double>.from(fields),
      photoPaths: List<String>.from(photoPaths),
      createdAt: createdAt,
    );
  }

  /// Create from domain entity
  factory MeasurementModel.fromEntity(Measurement entity) {
    return MeasurementModel(
      id: entity.id,
      customerId: entity.customerId,
      category: entity.category,
      fields: Map<String, double>.from(entity.fields),
      photoPaths: List<String>.from(entity.photoPaths),
      createdAt: entity.createdAt,
    );
  }
}
