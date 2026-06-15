import "package:equatable/equatable.dart";
import "package:tailor_app/domain/entities/staff.dart";

abstract class StaffEvent extends Equatable {
  const StaffEvent();

  @override
  List<Object?> get props => [];
}

class LoadStaff extends StaffEvent {
  const LoadStaff();
}

class AddStaff extends StaffEvent {
  final Staff staff;

  const AddStaff(this.staff);

  @override
  List<Object?> get props => [staff];
}

class UpdateStaff extends StaffEvent {
  final Staff staff;

  const UpdateStaff(this.staff);

  @override
  List<Object?> get props => [staff];
}

class DeleteStaff extends StaffEvent {
  final String id;

  const DeleteStaff(this.id);

  @override
  List<Object?> get props => [id];
}
