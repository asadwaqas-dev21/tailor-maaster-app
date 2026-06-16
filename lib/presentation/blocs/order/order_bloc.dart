import "dart:async";
import "package:flutter_bloc/flutter_bloc.dart";
import "package:tailor_app/domain/repositories/order_repository.dart";
import "package:tailor_app/presentation/blocs/order/order_event.dart";
import "package:tailor_app/presentation/blocs/order/order_state.dart";

class OrderBloc extends Bloc<OrderEvent, OrderState> {
  final OrderRepository _repository;
  StreamSubscription? _orderSubscription;

  OrderBloc({required this._repository}) : super(const OrderInitial()) {
    on<LoadOrders>(_onLoadOrders);
    on<FilterOrders>(_onFilterOrders);
    on<AddOrder>(_onAddOrder);
    on<UpdateOrder>(_onUpdateOrder);
    on<UpdateOrderStatus>(_onUpdateOrderStatus);
    on<DeleteOrder>(_onDeleteOrder);

    _orderSubscription = _repository.orderChanges.listen((_) {
      final currentState = state;
      if (currentState is OrderLoaded) {
        add(FilterOrders(status: currentState.filterStatus));
      } else {
        add(const LoadOrders());
      }
    });
  }

  @override
  Future<void> close() {
    _orderSubscription?.cancel();
    return super.close();
  }

  void _onLoadOrders(LoadOrders event, Emitter<OrderState> emit) {
    emit(const OrderLoading());
    try {
      final orders = _repository.getAllOrders();
      emit(OrderLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  void _onFilterOrders(FilterOrders event, Emitter<OrderState> emit) {
    try {
      final orders = event.status == null
          ? _repository.getAllOrders()
          : _repository.getOrdersByStatus(event.status!);
      emit(OrderLoaded(orders: orders, filterStatus: event.status));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onAddOrder(AddOrder event, Emitter<OrderState> emit) async {
    try {
      await _repository.addOrder(event.order);
      final orders = _repository.getAllOrders();
      emit(OrderLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onUpdateOrder(
    UpdateOrder event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await _repository.updateOrder(event.order);
      final orders = _repository.getAllOrders();
      emit(OrderLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onUpdateOrderStatus(
    UpdateOrderStatus event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await _repository.updateOrderStatus(event.orderId, event.status);
      final currentState = state;
      if (currentState is OrderLoaded) {
        final orders = currentState.filterStatus == null
            ? _repository.getAllOrders()
            : _repository.getOrdersByStatus(currentState.filterStatus!);
        emit(
          OrderLoaded(orders: orders, filterStatus: currentState.filterStatus),
        );
      } else {
        final orders = _repository.getAllOrders();
        emit(OrderLoaded(orders: orders));
      }
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }

  Future<void> _onDeleteOrder(
    DeleteOrder event,
    Emitter<OrderState> emit,
  ) async {
    try {
      await _repository.deleteOrder(event.id);
      final orders = _repository.getAllOrders();
      emit(OrderLoaded(orders: orders));
    } catch (e) {
      emit(OrderError(e.toString()));
    }
  }
}
