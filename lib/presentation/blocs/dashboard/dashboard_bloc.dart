import "dart:async";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/services/hive_service.dart";
import "package:tailor_app/domain/repositories/customer_repository.dart";
import "package:tailor_app/domain/repositories/order_repository.dart";
import "package:tailor_app/presentation/blocs/dashboard/dashboard_event.dart";
import "package:tailor_app/presentation/blocs/dashboard/dashboard_state.dart";

class DashboardBloc extends Bloc<DashboardEvent, DashboardState> {
  final OrderRepository _orderRepository;
  final CustomerRepository _customerRepository;
  StreamSubscription? _orderSubscription;

  DashboardBloc({
    required this._orderRepository,
    required this._customerRepository,
  }) : super(const DashboardInitial()) {
    on<LoadDashboard>(_onLoadDashboard);

    _orderSubscription = _orderRepository.orderChanges.listen((_) {
      add(const LoadDashboard());
    });
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }

  void _onLoadDashboard(LoadDashboard event, Emitter<DashboardState> emit) {
    emit(const DashboardLoading());
    try {
      final settingsBox = HiveService.settingsBox;
      final userRole = settingsBox.get("userRole", defaultValue: "owner") as String;
      final stitcherId = settingsBox.get("selectedStitcherId") as String?;

      final allOrders = _orderRepository.getAllOrders();

      if (userRole == "stitcher" && stitcherId != null) {
        // Stitcher mode: load only their assigned orders
        final assignedOrders = allOrders
            .where((o) => o.assignedStaffId == stitcherId)
            .toList()
          ..sort((a, b) => b.deliveryDate.compareTo(a.deliveryDate));

        int completedCount = 0;
        double pendingPayment = 0;
        double receivedPayment = 0;

        for (final o in assignedOrders) {
          if (o.status == OrderStatus.delivered || o.status == OrderStatus.ready) {
            completedCount++;
          }
          if (o.isStitcherPaid) {
            receivedPayment += o.stitchingCost;
          } else {
            pendingPayment += o.stitchingCost;
          }
        }

        emit(
          DashboardLoaded(
            recentOrders: const [],
            pendingOrders: const [],
            totalUnpaid: 0.0,
            totalOrders: assignedOrders.length,
            totalCustomers: 0,
            userRole: "stitcher",
            stitcherPendingPayment: pendingPayment,
            stitcherReceivedPayment: receivedPayment,
            stitcherCompletedOrders: completedCount,
            stitcherAssignedOrders: assignedOrders,
          ),
        );
      } else {
        // Owner mode: standard dashboard data
        final allOrders = _orderRepository.getAllOrders();
        final recentOrders = allOrders.take(5).toList();
        final pendingOrders = _orderRepository.getPendingOrders();
        final totalUnpaid = _orderRepository.getTotalUnpaidAmount();
        final totalOrders = _orderRepository.orderCount;
        final totalCustomers = _customerRepository.customerCount;

        emit(
          DashboardLoaded(
            recentOrders: recentOrders,
            pendingOrders: pendingOrders,
            totalUnpaid: totalUnpaid,
            totalOrders: totalOrders,
            totalCustomers: totalCustomers,
            userRole: "owner",
          ),
        );
      }
    } catch (e) {
      emit(DashboardError(e.toString()));
    }
  }
}
