import "package:flutter_bloc/flutter_bloc.dart";
import "package:intl/intl.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/domain/repositories/order_repository.dart";
import "package:tailor_app/presentation/blocs/report/report_event.dart";
import "package:tailor_app/presentation/blocs/report/report_state.dart";

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  final OrderRepository _orderRepository;

  ReportBloc({required this._orderRepository}) : super(const ReportInitial()) {
    on<LoadReport>(_onLoadReport);
  }

  void _onLoadReport(LoadReport event, Emitter<ReportState> emit) {
    emit(const ReportLoading());
    try {
      final allOrders = _orderRepository.getAllOrders();
      final now = DateTime.now();

      DateTime startDate;
      switch (event.period) {
        case ReportPeriod.daily:
          startDate = now.subtract(const Duration(days: 6));
          break;
        case ReportPeriod.weekly:
          startDate = now.subtract(const Duration(days: 7 * 4));
          break;
        case ReportPeriod.monthly:
          startDate = DateTime(now.year, now.month - 5, 1);
          break;
      }

      final filteredOrders = allOrders.where(
        (o) => o.orderDate.isAfter(startDate.subtract(const Duration(days: 1))),
      );

      double totalSales = 0;
      double totalAdvance = 0;
      double totalRemaining = 0;
      int totalOrdersCompleted = 0;

      final Map<String, double> groupedData = {};

      // Initialize map with empty values depending on period
      if (event.period == ReportPeriod.daily) {
        for (int i = 6; i >= 0; i--) {
          final date = now.subtract(Duration(days: i));
          groupedData[DateFormat("EEE").format(date)] = 0;
        }
      } else if (event.period == ReportPeriod.weekly) {
        for (int i = 4; i >= 0; i--) {
          groupedData["Week ${4 - i}"] = 0;
        }
      } else if (event.period == ReportPeriod.monthly) {
        for (int i = 5; i >= 0; i--) {
          final date = DateTime(now.year, now.month - i, 1);
          groupedData[DateFormat("MMM").format(date)] = 0;
        }
      }

      for (final order in filteredOrders) {
        totalSales += order.totalAmount;
        totalAdvance += order.advanceAmount;
        totalRemaining += order.remainingAmount;
        if (order.status == OrderStatus.delivered) {
          totalOrdersCompleted++;
        }

        String key = "";
        if (event.period == ReportPeriod.daily) {
          key = DateFormat("EEE").format(order.orderDate);
        } else if (event.period == ReportPeriod.weekly) {
          final diff = now.difference(order.orderDate).inDays;
          final weekNum = 4 - (diff ~/ 7);
          key = "Week $weekNum";
        } else if (event.period == ReportPeriod.monthly) {
          key = DateFormat("MMM").format(order.orderDate);
        }

        if (groupedData.containsKey(key)) {
          groupedData[key] = groupedData[key]! + order.totalAmount;
        }
      }

      final chartData = groupedData.entries
          .map((e) => ChartDataPoint(e.key, e.value))
          .toList();

      emit(
        ReportLoaded(
          period: event.period,
          totalSales: totalSales,
          totalAdvance: totalAdvance,
          totalRemaining: totalRemaining,
          totalOrdersCompleted: totalOrdersCompleted,
          chartData: chartData,
        ),
      );
    } catch (e) {
      emit(ReportError(e.toString()));
    }
  }
}
