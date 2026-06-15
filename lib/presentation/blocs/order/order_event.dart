import "package:equatable/equatable.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/domain/entities/order.dart";

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

class LoadOrders extends OrderEvent {
  const LoadOrders();
}

class FilterOrders extends OrderEvent {
  final OrderStatus? status;

  const FilterOrders({this.status});

  @override
  List<Object?> get props => [status];
}

class AddOrder extends OrderEvent {
  final Order order;

  const AddOrder(this.order);

  @override
  List<Object?> get props => [order];
}

class UpdateOrder extends OrderEvent {
  final Order order;

  const UpdateOrder(this.order);

  @override
  List<Object?> get props => [order];
}

class UpdateOrderStatus extends OrderEvent {
  final String orderId;
  final OrderStatus status;

  const UpdateOrderStatus({required this.orderId, required this.status});

  @override
  List<Object?> get props => [orderId, status];
}

class DeleteOrder extends OrderEvent {
  final String id;

  const DeleteOrder(this.id);

  @override
  List<Object?> get props => [id];
}
