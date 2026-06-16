import "package:flutter/foundation.dart";
import "package:mailer/mailer.dart";
import "package:mailer/smtp_server.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/extensions/date_extensions.dart";
import "package:tailor_app/core/extensions/string_extensions.dart";
import "package:tailor_app/core/services/hive_service.dart";
import "package:tailor_app/domain/entities/order.dart";
import "package:url_launcher/url_launcher.dart";

enum EmailSendResult {
  sentAutomatically,
  openedMailClient,
  failed,
}

class EmailService {
  EmailService._();

  /// Send order confirmation receipt via Email
  static Future<EmailSendResult> sendOrderConfirmation({
    required String email,
    required Order order,
  }) async {
    final subject = "Order Confirmation - #${order.id.substring(0, 8).toUpperCase()}";
    final body = _buildOrderConfirmation(order);
    return await _sendEmail(email: email, subject: subject, body: body);
  }

  /// Send "Ready for Pickup" notification via Email
  static Future<EmailSendResult> sendReadyForPickup({
    required String email,
    required Order order,
  }) async {
    final subject = "Order Ready for Pickup - #${order.id.substring(0, 8).toUpperCase()}";
    final body = _buildReadyForPickup(order);
    return await _sendEmail(email: email, subject: subject, body: body);
  }

  /// Master function to handle background SMTP sending or mailto fallback
  static Future<EmailSendResult> _sendEmail({
    required String email,
    required String subject,
    required String body,
  }) async {
    final box = HiveService.settingsBox;
    final bool sendAutomatically = box.get("sendEmailsAutomatically", defaultValue: false) as bool;
    final String host = box.get("smtpHost", defaultValue: "") as String;
    final int port = box.get("smtpPort", defaultValue: 587) as int;
    final String sender = box.get("senderEmail", defaultValue: "") as String;
    final String password = box.get("smtpAppPassword", defaultValue: "") as String;

    if (sendAutomatically && host.isNotEmpty && sender.isNotEmpty && password.isNotEmpty) {
      try {
        final smtpServer = SmtpServer(
          host,
          port: port,
          ssl: port == 465,
          username: sender,
          password: password,
        );

        final message = Message()
          ..from = Address(sender, "TailorPro")
          ..recipients.add(email)
          ..subject = subject
          ..text = body;

        await send(message, smtpServer);
        return EmailSendResult.sentAutomatically;
      } catch (e) {
        debugPrint("SMTP Send failed: $e");
        rethrow;
      }
    }

    // Fallback: Open URL launcher with mailto
    final success = await _openEmail(email: email, subject: subject, body: body);
    return success ? EmailSendResult.openedMailClient : EmailSendResult.failed;
  }

  /// Build order confirmation message body
  static String _buildOrderConfirmation(Order order) {
    final buffer = StringBuffer();
    buffer.writeln("Dear ${order.customerName},");
    buffer.writeln("");
    buffer.writeln("Thank you for your order with TailorPro! Here are your order details:");
    buffer.writeln("");
    buffer.writeln("Order Summary:");
    buffer.writeln("- Order ID: #${order.id.substring(0, 8).toUpperCase()}");
    buffer.writeln("- Garment: ${order.garmentType.snakeToTitle}");
    buffer.writeln("- Quantity: ${order.quantity}");
    buffer.writeln("");
    buffer.writeln("Payment Details:");
    buffer.writeln("- Total Amount: ${AppConstants.currencySymbol} ${order.totalAmount.toStringAsFixed(0)}");
    buffer.writeln("- Advance Paid: ${AppConstants.currencySymbol} ${order.advanceAmount.toStringAsFixed(0)}");
    buffer.writeln("- Remaining Balance: ${AppConstants.currencySymbol} ${order.remainingAmount.toStringAsFixed(0)}");
    buffer.writeln("");
    buffer.writeln("Dates:");
    buffer.writeln("- Order Date: ${order.orderDate.formatted}");
    buffer.writeln("- Expected Delivery: ${order.deliveryDate.formatted}");
    if (order.fabricDetails != null && order.fabricDetails!.isNotEmpty) {
      buffer.writeln("- Fabric Details: ${order.fabricDetails}");
    }
    buffer.writeln("");
    buffer.writeln("Thank you for choosing us! 🙏");
    buffer.writeln("");
    buffer.writeln("Best regards,");
    buffer.writeln("TailorPro Team");
    return buffer.toString();
  }

  /// Build ready for pickup message body
  static String _buildReadyForPickup(Order order) {
    final buffer = StringBuffer();
    buffer.writeln("Dear ${order.customerName},");
    buffer.writeln("");
    buffer.writeln("We are pleased to inform you that your order for ${order.garmentType.snakeToTitle} (Qty: ${order.quantity}) is ready for pickup! 🎉");
    buffer.writeln("");
    buffer.writeln("Order Details:");
    buffer.writeln("- Order ID: #${order.id.substring(0, 8).toUpperCase()}");
    buffer.writeln("- Order Date: ${order.orderDate.formatted}");
    buffer.writeln("- Delivery Date: ${order.deliveryDate.formatted}");
    if (order.fabricDetails != null && order.fabricDetails!.isNotEmpty) {
      buffer.writeln("- Fabric: ${order.fabricDetails}");
    }
    buffer.writeln("");
    if (order.remainingAmount > 0) {
      buffer.writeln("Remaining Balance to Pay: ${AppConstants.currencySymbol} ${order.remainingAmount.toStringAsFixed(0)}");
      buffer.writeln("");
    }
    buffer.writeln("Please visit our shop at your convenience to collect your order.");
    buffer.writeln("");
    buffer.writeln("Thank you for choosing TailorPro! 🙏");
    buffer.writeln("");
    buffer.writeln("Best regards,");
    buffer.writeln("TailorPro Team");
    return buffer.toString();
  }

  /// Open default email client with pre-filled content
  static Future<bool> _openEmail({
    required String email,
    required String subject,
    required String body,
  }) async {
    final String urlString = "mailto:$email"
        "?subject=${Uri.encodeComponent(subject)}"
        "&body=${Uri.encodeComponent(body)}";
    final Uri emailLaunchUri = Uri.parse(urlString);

    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        return await launchUrl(emailLaunchUri);
      } else {
        debugPrint("Could not launch email client");
        return false;
      }
    } catch (e) {
      debugPrint("Failed to open Email: $e");
      return false;
    }
  }
}
