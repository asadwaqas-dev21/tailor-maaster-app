import "package:equatable/equatable.dart";
import "package:tailor_app/domain/entities/order.dart";
import "package:tailor_app/presentation/blocs/report/report_event.dart";

class ChartDataPoint extends Equatable {
  final String label;
  final double value;

  const ChartDataPoint(this.label, this.value);

  @override
  List<Object?> get props => [label, value];
}

abstract class ReportState extends Equatable {
  const ReportState();

  @override
  List<Object?> get props => [];
}

class ReportInitial extends ReportState {
  const ReportInitial();
}

class ReportLoading extends ReportState {
  const ReportLoading();
}

class ReportLoaded extends ReportState {
  final ReportPeriod period;
  final double totalSales;
  final double totalAdvance;
  final double totalRemaining;
  final int totalOrdersCompleted;
  final List<ChartDataPoint> chartData;
  final List<Order> baqayaOrders;

  const ReportLoaded({
    required this.period,
    required this.totalSales,
    required this.totalAdvance,
    required this.totalRemaining,
    required this.totalOrdersCompleted,
    required this.chartData,
    required this.baqayaOrders,
  });

  @override
  List<Object?> get props => [
        period,
        totalSales,
        totalAdvance,
        totalRemaining,
        totalOrdersCompleted,
        chartData,
        baqayaOrders,
      ];
}

class ReportError extends ReportState {
  final String message;

  const ReportError(this.message);

  @override
  List<Object?> get props => [message];
}
