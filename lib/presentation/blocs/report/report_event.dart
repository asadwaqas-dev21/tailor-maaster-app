import "package:equatable/equatable.dart";

enum ReportPeriod { daily, weekly, monthly }

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class LoadReport extends ReportEvent {
  final ReportPeriod period;

  const LoadReport({this.period = ReportPeriod.monthly});

  @override
  List<Object?> get props => [period];
}
