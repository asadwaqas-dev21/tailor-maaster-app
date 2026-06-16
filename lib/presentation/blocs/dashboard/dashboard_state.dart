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
  final List<Order> recentOrders;
  final List<Order> pendingOrders;
  final double totalUnpaid;
  final int totalOrders;
  final int totalCustomers;

  // Stitcher-specific fields
  final String userRole;
  final double stitcherPendingPayment;
  final double stitcherReceivedPayment;
  final int stitcherCompletedOrders;
  final List<Order> stitcherAssignedOrders;

  const DashboardLoaded({
    required this.recentOrders,
    required this.pendingOrders,
    required this.totalUnpaid,
    required this.totalOrders,
    required this.totalCustomers,
    this.userRole = "owner",
    this.stitcherPendingPayment = 0.0,
    this.stitcherReceivedPayment = 0.0,
    this.stitcherCompletedOrders = 0,
    this.stitcherAssignedOrders = const [],
  });

  @override
  List<Object?> get props => [
        recentOrders,
        pendingOrders,
        totalUnpaid,
        totalOrders,
        totalCustomers,
        userRole,
        stitcherPendingPayment,
        stitcherReceivedPayment,
        stitcherCompletedOrders,
        stitcherAssignedOrders,
      ];
}

class DashboardError extends DashboardState {
  final String message;

  const DashboardError(this.message);

  @override
  List<Object?> get props => [message];
}
