import "package:firebase_core/firebase_core.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:google_fonts/google_fonts.dart";
import "package:tailor_app/app/app.dart";
import "package:tailor_app/core/services/hive_service.dart";
import "package:tailor_app/core/services/notification_service.dart";
import "package:tailor_app/firebase_options.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent Google Fonts from fetching fonts over network in release
  // (avoids crashes when R8 strips HTTP classes)
  GoogleFonts.config.allowRuntimeFetching = false;

  // Lock orientation to portrait
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase (non-fatal if it fails)
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint("Firebase init failed: $e");
  }

  // Initialize services (non-fatal if they fail)
  try {
    await HiveService.init();
  } catch (e) {
    debugPrint("Hive init failed: $e");
  }

  try {
    await NotificationService.init();
  } catch (e) {
    debugPrint("Notification init failed: $e");
  }

  runApp(const TailorProApp());
}
