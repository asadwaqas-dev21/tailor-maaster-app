import "package:flutter/material.dart";
import "package:hive/hive.dart";

part "payment_status.g.dart";

@HiveType(typeId: 12)
enum PaymentStatus {
  @HiveField(0)
  unpaid,

  @HiveField(1)
  partial,

  @HiveField(2)
  paid,
}

extension PaymentStatusExtension on PaymentStatus {
  String get labelEn {
    switch (this) {
      case PaymentStatus.unpaid:
        return "Unpaid";
      case PaymentStatus.partial:
        return "Partial";
      case PaymentStatus.paid:
        return "Paid";
    }
  }

  String get labelUr {
    switch (this) {
      case PaymentStatus.unpaid:
        return "غیر ادا شدہ";
      case PaymentStatus.partial:
        return "جزوی";
      case PaymentStatus.paid:
        return "ادا شدہ";
    }
  }

  Color get color {
    switch (this) {
      case PaymentStatus.unpaid:
        return const Color(0xFFF44336);
      case PaymentStatus.partial:
        return const Color(0xFFFF9800);
      case PaymentStatus.paid:
        return const Color(0xFF4CAF50);
    }
  }

  IconData get icon {
    switch (this) {
      case PaymentStatus.unpaid:
        return Icons.money_off_rounded;
      case PaymentStatus.partial:
        return Icons.payments_outlined;
      case PaymentStatus.paid:
        return Icons.check_circle_rounded;
    }
  }
}
