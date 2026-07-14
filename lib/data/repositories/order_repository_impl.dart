import "package:flutter/foundation.dart";
import "package:hive/hive.dart";
import "package:tailor_app/core/constants/hive_boxes.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/enums/payment_status.dart";
import "package:tailor_app/data/models/order_model.dart";
import "package:tailor_app/domain/entities/order.dart";
import "package:tailor_app/domain/repositories/order_repository.dart";

class OrderRepositoryImpl implements OrderRepository {
  Box<OrderModel> get _box => Hive.box<OrderModel>(HiveBoxes.orders);

  @override
  List<Order> getAllOrders() {
    final models = _box.values.toList();
    models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Order? getOrderById(String id) {
    try {
      final model = _box.values.firstWhere((m) => m.id == id);
      return model.toEntity();
    } catch (_) {
      return null;
    }
  }

  @override
  List<Order> getOrdersByCustomerId(String customerId) {
    final models = _box.values
        .where((m) => m.customerId == customerId)
        .toList();
    models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  List<Order> getOrdersByStatus(OrderStatus status) {
    final models = _box.values.where((m) => m.status == status).toList();
    models.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  List<Order> getTodayDeliveries() {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    if (kDebugMode) {
      print("[DEBUG] getTodayDeliveries: now=$now, todayStart=$todayStart");
    }
    final models = _box.values.where((m) {
      final localDelivery = m.deliveryDate.toLocal();
      final isToday =
          localDelivery.year == now.year &&
          localDelivery.month == now.month &&
          localDelivery.day == now.day;
      if (kDebugMode) {
        print(
          "[DEBUG] Order ID=${m.id}, Customer=${m.customerName}, deliveryDate=${m.deliveryDate}, localDelivery=$localDelivery, isToday=$isToday, status=${m.status}",
        );
      }
      return isToday && m.status != OrderStatus.delivered;
    }).toList();
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  List<Order> getPendingOrders() {
    if (kDebugMode) {
      print("[DEBUG] getPendingOrders called");
    }
    final models = _box.values
        .where((m) => m.status != OrderStatus.delivered)
        .toList();
    models.sort((a, b) => a.deliveryDate.compareTo(b.deliveryDate));
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  double getTotalUnpaidAmount() {
    double total = 0;
    for (final model in _box.values) {
      if (model.paymentStatus != PaymentStatus.paid) {
        total += model.totalAmount - model.advanceAmount;
      }
    }
    return total;
  }

  @override
  Future<void> addOrder(Order order) async {
    final model = OrderModel.fromEntity(order);
    await _box.put(order.id, model);
  }

  @override
  Future<void> updateOrder(Order order) async {
    final model = OrderModel.fromEntity(order);
    await _box.put(order.id, model);
  }

  @override
  Future<void> updateOrderStatus(String id, OrderStatus status) async {
    final order = getOrderById(id);
    if (order != null) {
      final updated = order.copyWith(status: status);
      await updateOrder(updated);
    }
  }

  @override
  Future<void> deleteOrder(String id) async {
    await _box.delete(id);
  }

  @override
  int get orderCount => _box.length;

  @override
  Stream<void> get orderChanges => _box.watch();
}
