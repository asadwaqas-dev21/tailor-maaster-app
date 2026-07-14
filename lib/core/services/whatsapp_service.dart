import "package:flutter/foundation.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/extensions/date_extensions.dart";
import "package:tailor_app/core/extensions/string_extensions.dart";
import "package:tailor_app/core/services/shop_profile.dart";
import "package:tailor_app/domain/entities/order.dart";
import "package:url_launcher/url_launcher.dart";

class WhatsAppService {
  WhatsAppService._();

  static Future<void> sendOrderConfirmation({
    required String phone,
    required Order order,
  }) async {
    final message = _buildOrderConfirmation(order);
    await _openWhatsApp(phone: phone, message: message);
  }

  static Future<void> sendReadyForPickup({
    required String phone,
    required Order order,
  }) async {
    final message = _buildReadyForPickup(order);
    await _openWhatsApp(phone: phone, message: message);
  }

  static String _buildOrderConfirmation(Order order) {
    final shop = ShopProfile.load();
    final buffer = StringBuffer();
    buffer.writeln("✂️ *${shop.displayName} - Order Confirmation*");
    buffer.writeln("━━━━━━━━━━━━━━━━━━━");
    if (order.tokenCode.isNotEmpty || order.displayToken.isNotEmpty) {
      buffer.writeln("🎫 *Token:* ${order.displayToken}");
    }
    buffer.writeln("👤 *Customer:* ${order.customerName}");
    buffer.writeln("👔 *Garment:* ${order.garmentType.snakeToTitle}");
    buffer.writeln("📦 *Quantity:* ${order.quantity}");
    buffer.writeln("");
    buffer.writeln(
      "💰 *Total:* ${AppConstants.currencySymbol} ${order.totalAmount.toStringAsFixed(0)}",
    );
    buffer.writeln(
      "💵 *Advance:* ${AppConstants.currencySymbol} ${order.advanceAmount.toStringAsFixed(0)}",
    );
    buffer.writeln(
      "📊 *Baqaya:* ${AppConstants.currencySymbol} ${order.remainingAmount.toStringAsFixed(0)}",
    );
    buffer.writeln("");
    buffer.writeln("📅 *Order:* ${order.orderDate.formatted}");
    buffer.writeln("📅 *Delivery:* ${order.deliveryDate.formatted}");
    if (order.fabricDetails != null && order.fabricDetails!.isNotEmpty) {
      buffer.writeln("🧵 *Fabric:* ${order.fabricDetails}");
    }
    if (shop.phone.isNotEmpty) {
      buffer.writeln("");
      buffer.writeln("📞 ${shop.phone}");
    }
    buffer.writeln("");
    buffer.writeln("Shukriya — ${shop.displayName}");
    return buffer.toString();
  }

  static String _buildReadyForPickup(Order order) {
    final shop = ShopProfile.load();
    final buffer = StringBuffer();
    buffer.writeln("✅ *${shop.displayName} — Ready hai*");
    buffer.writeln("━━━━━━━━━━━━━━━━━━━");
    buffer.writeln("Assalam-o-alaikum ${order.customerName},");
    buffer.writeln("");
    buffer.writeln("Aapka ${order.garmentType.snakeToTitle} ready hai!");
    buffer.writeln("🎫 Token: ${order.displayToken}");
    buffer.writeln("");
    if (order.remainingAmount > 0) {
      buffer.writeln(
        "📊 *Baqaya:* ${AppConstants.currencySymbol} ${order.remainingAmount.toStringAsFixed(0)}",
      );
      buffer.writeln("");
    }
    buffer.writeln("Meherbani karke dukaan se le jayein.");
    if (shop.address.isNotEmpty) {
      buffer.writeln("📍 ${shop.address}");
    }
    buffer.writeln("");
    buffer.writeln("Shukriya!");
    buffer.writeln("*${shop.displayName}*");
    return buffer.toString();
  }

  static Future<void> _openWhatsApp({
    required String phone,
    required String message,
  }) async {
    final whatsAppNumber = phone.toWhatsAppNumber;
    final encodedMessage = Uri.encodeComponent(message);
    final url = Uri.parse(
      "${AppConstants.whatsAppBaseUrl}$whatsAppNumber?text=$encodedMessage",
    );

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      }
    } catch (e) {
      debugPrint("Failed to open WhatsApp: $e");
    }
  }
}
