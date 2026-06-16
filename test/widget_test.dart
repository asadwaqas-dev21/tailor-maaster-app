import "dart:io";
import "package:flutter/material.dart";
import "package:flutter_test/flutter_test.dart";
import "package:hive/hive.dart";
import "package:tailor_app/app/app.dart";
import "package:tailor_app/core/enums/gender.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/enums/payment_status.dart";
import "package:tailor_app/core/enums/staff_role.dart";
import "package:tailor_app/data/models/customer_model.dart";
import "package:tailor_app/data/models/measurement_model.dart";
import "package:tailor_app/data/models/order_model.dart";
import "package:tailor_app/data/models/staff_model.dart";

void main() {
  late Directory tempDir;

  setUpAll(() {
    Hive.registerAdapter(CustomerModelAdapter());
    Hive.registerAdapter(OrderModelAdapter());
    Hive.registerAdapter(MeasurementModelAdapter());
    Hive.registerAdapter(GenderAdapter());
    Hive.registerAdapter(OrderStatusAdapter());
    Hive.registerAdapter(PaymentStatusAdapter());
    Hive.registerAdapter(StaffModelAdapter());
    Hive.registerAdapter(StaffRoleAdapter());
  });

  setUp(() async {
    tempDir = Directory.systemTemp.createTempSync();
    Hive.init(tempDir.path);

    await Hive.openBox<CustomerModel>("customers");
    await Hive.openBox<OrderModel>("orders");
    await Hive.openBox<MeasurementModel>("measurements");
    await Hive.openBox<StaffModel>("staff");
    await Hive.openBox("app_settings");
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  testWidgets("App launch smoke test", (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const TailorProApp());

    // Verify that the splash screen shows the scissor icon
    expect(find.byIcon(Icons.content_cut_rounded), findsOneWidget);

    // Advance clock to allow navigation timer to complete and avoid pending timer error
    await tester.pump(const Duration(seconds: 3));
    await tester.pumpAndSettle();
  });
}
