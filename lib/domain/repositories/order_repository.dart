import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/domain/entities/order.dart";

abstract class OrderRepository {
  /// Get all orders sorted by creation date (newest first)
  List<Order> getAllOrders();

  /// Get order by ID
  Order? getOrderById(String id);

  /// Get orders by customer ID
  List<Order> getOrdersByCustomerId(String customerId);

  /// Get orders filtered by status
  List<Order> getOrdersByStatus(OrderStatus status);

  /// Get orders with delivery date today
  List<Order> getTodayDeliveries();

  /// Get all pending orders (not delivered)
  List<Order> getPendingOrders();

  /// Get total unpaid amount across all orders
  double getTotalUnpaidAmount();

  /// Add a new order
  Future<void> addOrder(Order order);

  /// Update an existing order
  Future<void> updateOrder(Order order);

  /// Update order status
  Future<void> updateOrderStatus(String id, OrderStatus status);

  /// Delete an order by ID
  Future<void> deleteOrder(String id);

  /// Get total order count
  int get orderCount;
}
