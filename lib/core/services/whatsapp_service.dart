import "package:flutter/foundation.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/extensions/date_extensions.dart";
import "package:tailor_app/core/extensions/string_extensions.dart";
import "package:tailor_app/domain/entities/order.dart";
import "package:url_launcher/url_launcher.dart";

class WhatsAppService {
  WhatsAppService._();

  /// Send order confirmation receipt via WhatsApp
  static Future<void> sendOrderConfirmation({
    required String phone,
    required Order order,
  }) async {
    final message = _buildOrderConfirmation(order);
    await _openWhatsApp(phone: phone, message: message);
  }

  /// Send "Ready for Pickup" notification via WhatsApp
  static Future<void> sendReadyForPickup({
    required String phone,
    required Order order,
  }) async {
    final message = _buildReadyForPickup(order);
    await _openWhatsApp(phone: phone, message: message);
  }

  /// Build order confirmation message
  static String _buildOrderConfirmation(Order order) {
    final buffer = StringBuffer();
    buffer.writeln("✂️ *Darzi - Order Confirmation*");
    buffer.writeln("━━━━━━━━━━━━━━━━━━━");
    buffer.writeln("👤 *Customer:* ${order.customerName}");
    buffer.writeln("👔 *Garment:* ${order.garmentType.snakeToTitle}");
    buffer.writeln("📦 *Quantity:* ${order.quantity}");
    buffer.writeln("");
    buffer.writeln("💰 *Total:* ${AppConstants.currencySymbol} ${order.totalAmount.toStringAsFixed(0)}");
    buffer.writeln("💵 *Advance:* ${AppConstants.currencySymbol} ${order.advanceAmount.toStringAsFixed(0)}");
    buffer.writeln("📊 *Remaining:* ${AppConstants.currencySymbol} ${order.remainingAmount.toStringAsFixed(0)}");
    buffer.writeln("");
    buffer.writeln("📅 *Order Date:* ${order.orderDate.formatted}");
    buffer.writeln("📅 *Delivery Date:* ${order.deliveryDate.formatted}");
    if (order.fabricDetails != null && order.fabricDetails!.isNotEmpty) {
      buffer.writeln("🧵 *Fabric:* ${order.fabricDetails}");
    }
    buffer.writeln("");
    buffer.writeln("Shukriya — Darzi 🙏");
    return buffer.toString();
  }

  /// Build ready for pickup message
  static String _buildReadyForPickup(Order order) {
    final buffer = StringBuffer();
    buffer.writeln("✅ *Darzi — Ready hai*");
    buffer.writeln("━━━━━━━━━━━━━━━━━━━");
    buffer.writeln("Assalam-o-alaikum ${order.customerName},");
    buffer.writeln("");
    buffer.writeln("Aapka ${order.garmentType.snakeToTitle} ready hai! 🎉");
    buffer.writeln("");
    if (order.remainingAmount > 0) {
      buffer.writeln("📊 *Baqaya:* ${AppConstants.currencySymbol} ${order.remainingAmount.toStringAsFixed(0)}");
      buffer.writeln("");
    }
    buffer.writeln("Meherbani karke dukaan se le jayein.");
    buffer.writeln("");
    buffer.writeln("Shukriya! 🙏");
    buffer.writeln("*Darzi*");
    return buffer.toString();
  }

  /// Open WhatsApp with pre-filled message
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
