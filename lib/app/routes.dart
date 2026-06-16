import "package:flutter/material.dart";
import "package:tailor_app/domain/entities/customer.dart";
import "package:tailor_app/domain/entities/measurement.dart";
import "package:tailor_app/domain/entities/order.dart";
import "package:tailor_app/presentation/screens/customer/customer_detail_screen.dart";
import "package:tailor_app/presentation/screens/customer/customer_form_screen.dart";
import "package:tailor_app/presentation/screens/main_shell.dart";
import "package:tailor_app/presentation/screens/measurement/measurement_form_screen.dart";
import "package:tailor_app/presentation/screens/order/order_detail_screen.dart";
import "package:tailor_app/presentation/screens/order/order_form_screen.dart";
import "package:tailor_app/presentation/screens/splash/splash_screen.dart";
import "package:tailor_app/domain/entities/staff.dart";
import "package:tailor_app/presentation/screens/staff/staff_list_screen.dart";
import "package:tailor_app/presentation/screens/staff/staff_form_screen.dart";
import "package:tailor_app/presentation/screens/staff/staff_detail_screen.dart";
import "package:tailor_app/presentation/screens/report/report_screen.dart";
import "package:tailor_app/presentation/screens/notification/notification_screen.dart";

class AppRoutes {
  AppRoutes._();

  static const String splash = "/";
  static const String main = "/main";
  static const String customerForm = "/customer/form";
  static const String customerDetail = "/customer/detail";
  static const String orderForm = "/order/form";
  static const String orderDetail = "/order/detail";
  static const String measurementForm = "/measurement/form";
  static const String staffList = "/staff/list";
  static const String staffForm = "/staff/form";
  static const String staffDetail = "/staff/detail";
  static const String report = "/report";
  static const String notification = "/notification";

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _fadeRoute(const SplashScreen());

      case main:
        return _fadeRoute(const MainShell());

      case customerForm:
        final customer = settings.arguments as Customer?;
        return _slideRoute(CustomerFormScreen(customer: customer));

      case customerDetail:
        final customerId = settings.arguments as String;
        return _slideRoute(
            CustomerDetailScreen(customerId: customerId));

      case orderForm:
        if (settings.arguments is Order) {
          return _slideRoute(OrderFormScreen(order: settings.arguments as Order));
        } else if (settings.arguments is String) {
          return _slideRoute(OrderFormScreen(customerId: settings.arguments as String));
        }
        return _slideRoute(const OrderFormScreen());

      case orderDetail:
        final orderId = settings.arguments as String;
        return _slideRoute(OrderDetailScreen(orderId: orderId));

      case measurementForm:
        final args = settings.arguments as Map<String, dynamic>;
        final customerId = args["customerId"] as String;
        final measurement = args["measurement"] as Measurement?;
        return _slideRoute(MeasurementFormScreen(
          customerId: customerId,
          measurement: measurement,
        ));

      case staffList:
        return _slideRoute(const StaffListScreen());

      case staffForm:
        final staff = settings.arguments as Staff?;
        return _slideRoute(StaffFormScreen(staff: staff));

      case staffDetail:
        final staffId = settings.arguments as String;
        return _slideRoute(StaffDetailScreen(staffId: staffId));

      case report:
        return _slideRoute(const ReportScreen());

      case notification:
        return _slideRoute(const NotificationScreen());

      default:
        return _fadeRoute(const SplashScreen());
    }
  }

  static Route<dynamic> _fadeRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(opacity: animation, child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }

  static Route<dynamic> _slideRoute(Widget page) {
    return PageRouteBuilder(
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final tween = Tween(begin: const Offset(1, 0), end: Offset.zero)
            .chain(CurveTween(curve: Curves.easeOutCubic));
        return SlideTransition(position: animation.drive(tween), child: child);
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
