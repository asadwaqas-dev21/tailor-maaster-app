import "package:equatable/equatable.dart";
import "package:tailor_app/domain/entities/measurement.dart";

abstract class MeasurementState extends Equatable {
  const MeasurementState();

  @override
  List<Object?> get props => [];
}

class MeasurementInitial extends MeasurementState {
  const MeasurementInitial();
}

class MeasurementLoading extends MeasurementState {
  const MeasurementLoading();
}

class MeasurementLoaded extends MeasurementState {
  final List<Measurement> measurements;

  const MeasurementLoaded({required this.measurements});

  @override
  List<Object?> get props => [measurements];
}

class MeasurementError extends MeasurementState {
  final String message;

  const MeasurementError(this.message);

  @override
  List<Object?> get props => [message];
}
