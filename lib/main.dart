import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:google_fonts/google_fonts.dart";
import "package:tailor_app/app/app.dart";
import "package:tailor_app/core/services/hive_service.dart";
import "package:tailor_app/core/services/notification_service.dart";
import "package:tailor_app/core/services/supabase_service.dart";

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Prevent Google Fonts from fetching fonts over network in release
  GoogleFonts.config.allowRuntimeFetching = false;

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    debugPrint("dotenv load skipped: $e");
  }

  try {
    await SupabaseService.init();
  } catch (e) {
    debugPrint("Supabase init failed: $e");
  }

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
