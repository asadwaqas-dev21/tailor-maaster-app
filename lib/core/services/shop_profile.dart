import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/services/hive_service.dart";

/// Dukan profile stored in Hive settings box.
class ShopProfile {
  final String name;
  final String phone;
  final String address;

  const ShopProfile({
    required this.name,
    required this.phone,
    required this.address,
  });

  static const String defaultName = "Chughtai Tailors";

  factory ShopProfile.load() {
    final box = HiveService.settingsBox;
    return ShopProfile(
      name: (box.get("shopName") as String?)?.trim().isNotEmpty == true
          ? (box.get("shopName") as String).trim()
          : defaultName,
      phone: (box.get("shopPhone") as String?)?.trim() ?? "",
      address: (box.get("shopAddress") as String?)?.trim() ?? "",
    );
  }

  static Future<void> save({
    required String name,
    required String phone,
    required String address,
  }) async {
    final box = HiveService.settingsBox;
    await box.put("shopName", name.trim().isEmpty ? defaultName : name.trim());
    await box.put("shopPhone", phone.trim());
    await box.put("shopAddress", address.trim());
  }

  String get displayName => name.isEmpty ? AppConstants.appName : name;
}
