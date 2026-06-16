import "dart:io";
import "package:flutter_test/flutter_test.dart";
import "package:hive/hive.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/enums/payment_status.dart";
import "package:tailor_app/data/models/order_model.dart";
import "package:tailor_app/data/repositories/order_repository_impl.dart";
import "package:tailor_app/domain/entities/order.dart";

void main() {
  late Directory tempDir;

  setUpAll(() {
    Hive.registerAdapter(OrderModelAdapter());
    Hive.registerAdapter(OrderStatusAdapter());
    Hive.registerAdapter(PaymentStatusAdapter());
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  test("test today deliveries after serialization", () async {
    {
      final box = await Hive.openBox<OrderModel>("orders");
      final repo = OrderRepositoryImpl();
      
      final todayWithTime = DateTime.now();
      final orderWithTime = Order(
        id: "1",
        customerId: "cust1",
        customerName: "Customer 1",
        garmentType: "shirt",
        quantity: 1,
        totalAmount: 100,
        advanceAmount: 10,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.partial,
        orderDate: todayWithTime,
        deliveryDate: todayWithTime,
        createdAt: todayWithTime,
      );
      await repo.addOrder(orderWithTime);

      final todayMidnight = DateTime(todayWithTime.year, todayWithTime.month, todayWithTime.day);
      final orderMidnight = Order(
        id: "2",
        customerId: "cust2",
        customerName: "Customer 2",
        garmentType: "shirt",
        quantity: 1,
        totalAmount: 120,
        advanceAmount: 20,
        status: OrderStatus.stitching,
        paymentStatus: PaymentStatus.partial,
        orderDate: todayMidnight,
        deliveryDate: todayMidnight,
        createdAt: todayMidnight,
      );
      await repo.addOrder(orderMidnight);
      
      await box.close();
    }

    {
      await Hive.openBox<OrderModel>("orders");
      final repo = OrderRepositoryImpl();
      final deliveries = repo.getTodayDeliveries();
      
      expect(deliveries.length, 2);
    }
  });

  test("test staff assignment preservation across saves and updates", () async {
    // 1. Create order with staff assigned and write to Hive
    {
      final box = await Hive.openBox<OrderModel>("orders");
      final repo = OrderRepositoryImpl();
      final today = DateTime.now();
      final order = Order(
        id: "staff_test_id",
        customerId: "c1",
        customerName: "Customer 1",
        garmentType: "kurta",
        quantity: 1,
        totalAmount: 1500,
        advanceAmount: 500,
        status: OrderStatus.pending,
        paymentStatus: PaymentStatus.partial,
        orderDate: today,
        deliveryDate: today,
        createdAt: today,
        assignedStaffId: "staff_123",
        assignedStaffName: "John Doe",
      );
      await repo.addOrder(order);
      await box.close();
    }

    // 2. Read back from Hive and verify staff fields are populated
    {
      final box = await Hive.openBox<OrderModel>("orders");
      final repo = OrderRepositoryImpl();
      var order = repo.getOrderById("staff_test_id");
      expect(order, isNotNull);
      expect(order!.assignedStaffId, "staff_123");
      expect(order.assignedStaffName, "John Doe");

      // 3. Update status (calls copyWith under the hood) and verify fields are preserved
      await repo.updateOrderStatus("staff_test_id", OrderStatus.cutting);
      await box.close();
    }

    // 4. Read back and verify again
    {
      await Hive.openBox<OrderModel>("orders");
      final repo = OrderRepositoryImpl();
      final order = repo.getOrderById("staff_test_id");
      expect(order, isNotNull);
      expect(order!.status, OrderStatus.cutting);
      expect(order.assignedStaffId, "staff_123");
      expect(order.assignedStaffName, "John Doe");
    }
  });
}
