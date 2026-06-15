import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:tailor_app/app/app.dart";
import "package:tailor_app/core/services/hive_service.dart";
import "package:tailor_app/core/services/notification_service.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize services
  await HiveService.init();
  await NotificationService.init();

  runApp(const TailorProApp());
}
