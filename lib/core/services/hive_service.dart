import "package:hive_flutter/hive_flutter.dart";
import "package:tailor_app/core/constants/hive_boxes.dart";
import "package:tailor_app/core/enums/gender.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/enums/payment_status.dart";
import "package:tailor_app/data/models/customer_model.dart";
import "package:tailor_app/data/models/measurement_model.dart";
import "package:tailor_app/data/models/order_model.dart";
import "package:tailor_app/data/models/staff_model.dart";
import "package:tailor_app/core/enums/staff_role.dart";

class HiveService {
  HiveService._();

  static Future<void> init() async {
    await Hive.initFlutter();
    _registerAdapters();
    await _openBoxes();
  }

  static void _registerAdapters() {
    Hive.registerAdapter(CustomerModelAdapter());
    Hive.registerAdapter(OrderModelAdapter());
    Hive.registerAdapter(MeasurementModelAdapter());
    Hive.registerAdapter(GenderAdapter());
    Hive.registerAdapter(OrderStatusAdapter());
    Hive.registerAdapter(PaymentStatusAdapter());
    Hive.registerAdapter(StaffModelAdapter());
    Hive.registerAdapter(StaffRoleAdapter());
  }

  static Future<void> _openBoxes() async {
    await Hive.openBox<CustomerModel>(HiveBoxes.customers);
    await Hive.openBox<OrderModel>(HiveBoxes.orders);
    await Hive.openBox<MeasurementModel>(HiveBoxes.measurements);
    await Hive.openBox<StaffModel>(HiveBoxes.staff);
    await Hive.openBox(HiveBoxes.settings);
  }

  /// Get settings box for theme/locale persistence
  static Box get settingsBox => Hive.box(HiveBoxes.settings);

  /// Close all boxes
  static Future<void> close() async {
    await Hive.close();
  }
}
