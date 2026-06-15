import "package:tailor_app/domain/entities/measurement.dart";

abstract class MeasurementRepository {
  /// Get all measurements
  List<Measurement> getAllMeasurements();

  /// Get measurement by ID
  Measurement? getMeasurementById(String id);

  /// Get measurements by customer ID
  List<Measurement> getMeasurementsByCustomerId(String customerId);

  /// Add a new measurement
  Future<void> addMeasurement(Measurement measurement);

  /// Update an existing measurement
  Future<void> updateMeasurement(Measurement measurement);

  /// Delete a measurement by ID
  Future<void> deleteMeasurement(String id);
}
