import "package:equatable/equatable.dart";
import "package:tailor_app/domain/entities/order.dart";

abstract class DashboardState extends Equatable {
  const DashboardState();

  @override
  List<Object?> get props => [];
}

class DashboardInitial extends DashboardState {
  const DashboardInitial();
}

class DashboardLoading extends DashboardState {
  const DashboardLoading();
}

class DashboardLoaded extends DashboardState {
  final List<Order> todayDeliveries;
  final List<Order> pendingOrders;
  final double totalUnpaid;
  final int totalOrders;
  final int totalCustomers;

  const DashboardLoaded({
    required this.todayDeliveries,
    required this.pendingOrders,
    required this.totalUnpaid,
    required this.totalOrders,
    required this.totalCustomers,
  });

  @override
  List<Object?> get props =>
      [todayDeliveries, pendingOrders, totalUnpaid, totalOrders, totalCustomers];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
