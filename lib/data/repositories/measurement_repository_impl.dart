import "package:hive/hive.dart";
import "package:tailor_app/core/constants/hive_boxes.dart";
import "package:tailor_app/data/models/measurement_model.dart";
import "package:tailor_app/domain/entities/measurement.dart";
import "package:tailor_app/domain/repositories/measurement_repository.dart";

class MeasurementRepositoryImpl implements MeasurementRepository {
  Box<MeasurementModel> get _box =>
      Hive.box<MeasurementModel>(HiveBoxes.measurements);

  @override
  List<Measurement> getAllMeasurements() {
    final models = _box.values.toList();
    models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Measurement? getMeasurementById(String id) {
    try {
      final model = _box.values.firstWhere((m) => m.id == id);
      return model.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  List<Measurement> getMeasurementsByCustomerId(String customerId) {
    final models = _box.values
        .where((m) => m.customerId == customerId)
        .toList();
    models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<void> addMeasurement(Measurement measurement) async {
    final model = MeasurementModel.fromEntity(measurement);
    await _box.put(measurement.id, model);
  }

  @override
  Future<void> updateMeasurement(Measurement measurement) async {
    final model = MeasurementModel.fromEntity(measurement);
    await _box.put(measurement.id, model);
  }

  @override
  Future<void> deleteMeasurement(String id) async {
    await _box.delete(id);
  }
}
