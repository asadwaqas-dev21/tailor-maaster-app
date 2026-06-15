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
    buffer.writeln("✂️ *TailorPro - Order Confirmation*");
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
    buffer.writeln("Thank you for choosing TailorPro! 🙏");
    return buffer.toString();
  }

  /// Build ready for pickup message
  static String _buildReadyForPickup(Order order) {
    final buffer = StringBuffer();
    buffer.writeln("✅ *TailorPro - Ready for Pickup*");
    buffer.writeln("━━━━━━━━━━━━━━━━━━━");
    buffer.writeln("Dear ${order.customerName},");
    buffer.writeln("");
    buffer.writeln("Your ${order.garmentType.snakeToTitle} is ready! 🎉");
    buffer.writeln("");
    if (order.remainingAmount > 0) {
      buffer.writeln("📊 *Remaining Balance:* ${AppConstants.currencySymbol} ${order.remainingAmount.toStringAsFixed(0)}");
      buffer.writeln("");
    }
    buffer.writeln("Please visit our shop at your convenience to collect your order.");
    buffer.writeln("");
    buffer.writeln("Thank you! 🙏");
    buffer.writeln("*TailorPro*");
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
