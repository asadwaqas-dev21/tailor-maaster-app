import "package:equatable/equatable.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/domain/entities/order.dart";

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

class OrderInitial extends OrderState {
  const OrderInitial();
}

class OrderLoading extends OrderState {
  const OrderLoading();
}

class OrderLoaded extends OrderState {
  final List<Order> orders;
  final OrderStatus? filterStatus;

  const OrderLoaded({
    required this.orders,
    this.filterStatus,
  });

  @override
  List<Object?> get props => [orders, filterStatus];
}

class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}
