import "package:equatable/equatable.dart";
import "package:tailor_app/domain/entities/staff.dart";

abstract class StaffState extends Equatable {
  const StaffState();

  @override
  List<Object?> get props => [];
}

class StaffInitial extends StaffState {
  const StaffInitial();
}

class StaffLoading extends StaffState {
  const StaffLoading();
}

class StaffLoaded extends StaffState {
  final List<Staff> staffMembers;

  const StaffLoaded({required this.staffMembers});

  @override
  List<Object?> get props => [staffMembers];
}

class StaffError extends StaffState {
  final String message;

  const StaffError(this.message);

  @override
  List<Object?> get props => [message];
}
