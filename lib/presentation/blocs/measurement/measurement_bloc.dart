import "package:flutter_bloc/flutter_bloc.dart";
import "package:tailor_app/domain/repositories/measurement_repository.dart";
import "package:tailor_app/presentation/blocs/measurement/measurement_event.dart";
import "package:tailor_app/presentation/blocs/measurement/measurement_state.dart";

class MeasurementBloc extends Bloc<MeasurementEvent, MeasurementState> {
  final MeasurementRepository _repository;

  MeasurementBloc({required this._repository})
    : super(const MeasurementInitial()) {
    on<LoadMeasurements>(_onLoadMeasurements);
    on<LoadMeasurementsByCustomer>(_onLoadByCustomer);
    on<AddMeasurement>(_onAddMeasurement);
    on<UpdateMeasurement>(_onUpdateMeasurement);
    on<DeleteMeasurement>(_onDeleteMeasurement);
  }

  void _onLoadMeasurements(
    LoadMeasurements event,
    Emitter<MeasurementState> emit,
  ) {
    emit(const MeasurementLoading());
    try {
      final measurements = _repository.getAllMeasurements();
      emit(MeasurementLoaded(measurements: measurements));
    } catch (e) {
      emit(MeasurementError(e.toString()));
    }
  }

  void _onLoadByCustomer(
    LoadMeasurementsByCustomer event,
    Emitter<MeasurementState> emit,
  ) {
    try {
      final measurements = _repository.getMeasurementsByCustomerId(
        event.customerId,
      );
      emit(MeasurementLoaded(measurements: measurements));
    } catch (e) {
      emit(MeasurementError(e.toString()));
    }
  }

  Future<void> _onAddMeasurement(
    AddMeasurement event,
    Emitter<MeasurementState> emit,
  ) async {
    try {
      await _repository.addMeasurement(event.measurement);
      final measurements = _repository.getAllMeasurements();
      emit(MeasurementLoaded(measurements: measurements));
    } catch (e) {
      emit(MeasurementError(e.toString()));
    }
  }

  Future<void> _onUpdateMeasurement(
    UpdateMeasurement event,
    Emitter<MeasurementState> emit,
  ) async {
    try {
      await _repository.updateMeasurement(event.measurement);
      final measurements = _repository.getAllMeasurements();
      emit(MeasurementLoaded(measurements: measurements));
    } catch (e) {
      emit(MeasurementError(e.toString()));
    }
  }

  Future<void> _onDeleteMeasurement(
    DeleteMeasurement event,
    Emitter<MeasurementState> emit,
  ) async {
    try {
      await _repository.deleteMeasurement(event.id);
      final measurements = _repository.getAllMeasurements();
      emit(MeasurementLoaded(measurements: measurements));
    } catch (e) {
      emit(MeasurementError(e.toString()));
    }
  }
}
