import "package:flutter_bloc/flutter_bloc.dart";
import "package:tailor_app/domain/repositories/staff_repository.dart";
import "package:tailor_app/presentation/blocs/staff/staff_event.dart";
import "package:tailor_app/presentation/blocs/staff/staff_state.dart";

class StaffBloc extends Bloc<StaffEvent, StaffState> {
  final StaffRepository _repository;

  StaffBloc({required this._repository}) : super(const StaffInitial()) {
    on<LoadStaff>(_onLoadStaff);
    on<AddStaff>(_onAddStaff);
    on<UpdateStaff>(_onUpdateStaff);
    on<DeleteStaff>(_onDeleteStaff);
  }

  void _onLoadStaff(LoadStaff event, Emitter<StaffState> emit) {
    emit(const StaffLoading());
    try {
      final staffList = _repository.getAllStaff();
      emit(StaffLoaded(staffMembers: staffList));
    } catch (e) {
      emit(StaffError(e.toString()));
    }
  }

  Future<void> _onAddStaff(AddStaff event, Emitter<StaffState> emit) async {
    try {
      await _repository.addStaff(event.staff);
      final staffList = _repository.getAllStaff();
      emit(StaffLoaded(staffMembers: staffList));
    } catch (e) {
      emit(StaffError(e.toString()));
    }
  }

  Future<void> _onUpdateStaff(
    UpdateStaff event,
    Emitter<StaffState> emit,
  ) async {
    try {
      await _repository.updateStaff(event.staff);
      final staffList = _repository.getAllStaff();
      emit(StaffLoaded(staffMembers: staffList));
    } catch (e) {
      emit(StaffError(e.toString()));
    }
  }

  Future<void> _onDeleteStaff(
    DeleteStaff event,
    Emitter<StaffState> emit,
  ) async {
    try {
      await _repository.deleteStaff(event.id);
      final staffList = _repository.getAllStaff();
      emit(StaffLoaded(staffMembers: staffList));
    } catch (e) {
      emit(StaffError(e.toString()));
    }
  }
}
