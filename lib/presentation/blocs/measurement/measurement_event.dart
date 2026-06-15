import "package:equatable/equatable.dart";
import "package:tailor_app/domain/entities/measurement.dart";

abstract class MeasurementEvent extends Equatable {
  const MeasurementEvent();

  @override
  List<Object?> get props => [];
}

class LoadMeasurements extends MeasurementEvent {
  const LoadMeasurements();
}

class LoadMeasurementsByCustomer extends MeasurementEvent {
  final String customerId;

  const LoadMeasurementsByCustomer(this.customerId);

  @override
  List<Object?> get props => [customerId];
}

class AddMeasurement extends MeasurementEvent {
  final Measurement measurement;

  const AddMeasurement(this.measurement);

  @override
  List<Object?> get props => [measurement];
}

class UpdateMeasurement extends MeasurementEvent {
  final Measurement measurement;

  const UpdateMeasurement(this.measurement);

  @override
  List<Object?> get props => [measurement];
}

class DeleteMeasurement extends MeasurementEvent {
  final String id;

  const DeleteMeasurement(this.id);

  @override
  List<Object?> get props => [id];
}
