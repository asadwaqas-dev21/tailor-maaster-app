import "package:flutter_bloc/flutter_bloc.dart";
import "package:tailor_app/domain/repositories/customer_repository.dart";
import "package:tailor_app/domain/repositories/order_repository.dart";
import "package:tailor_app/presentation/blocs/dashboard/dashboard_event.dart";
import "package:tailor_app/presentation/blocs/dashboard/dashboard_state.dart";

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final OrderRepository _orderRepository;
  final CustomerRepository _customerRepository;

  DashboardBloc({
    required this._orderRepository,
    required this._customerRepository,
  }) : super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);
  }

  void _onLoadDashboard(LoadDashboard event, Emitter<DashboardState> emit) {
    emit(const DashboardLoading());
    try {
      final todayDeliveries = _orderRepository.getTodayDeliveries();
      final pendingOrders = _orderRepository.getPendingOrders();
      final totalUnpaid = _orderRepository.getTotalUnpaidAmount();
      final totalOrders = _orderRepository.orderCount;
      final totalCustomers = _customerRepository.customerCount;

      emit(
        DashboardLoaded(
          todayDeliveries: todayDeliveries,
          pendingOrders: pendingOrders,
          totalUnpaid: totalUnpaid,
          totalOrders: totalOrders,
          totalCustomers: totalCustomers,
        ),
      );
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
