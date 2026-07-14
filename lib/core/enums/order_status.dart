import "package:flutter/material.dart";
import "package:hive/hive.dart";

part "order_status.g.dart";

@HiveType(typeId: 11)
enum OrderStatus {
  @HiveField(0)
  pending,

  @HiveField(1)
  cutting,

  @HiveField(2)
  stitching,

  @HiveField(3)
  ready,

  @HiveField(4)
  delivered,
}

extension OrderStatusExtension on OrderStatus {
  String get labelEn {
    switch (this) {
      case OrderStatus.pending:
        return "Pending";
      case OrderStatus.cutting:
        return "Cutting";
      case OrderStatus.stitching:
        return "Stitching";
      case OrderStatus.ready:
        return "Ready";
      case OrderStatus.delivered:
        return "Delivered";
    }
  }

  String get labelUr {
    switch (this) {
      case OrderStatus.pending:
        return "زیر التوا";
      case OrderStatus.cutting:
        return "کٹائی";
      case OrderStatus.stitching:
        return "سلائی";
      case OrderStatus.ready:
        return "تیار";
      case OrderStatus.delivered:
        return "ڈیلیور";
    }
  }

  Color get color {
    switch (this) {
      case OrderStatus.pending:
        return const Color(0xFFA9791B);
      case OrderStatus.cutting:
        return const Color(0xFFA9791B);
      case OrderStatus.stitching:
        return const Color(0xFF1D6F62);
      case OrderStatus.ready:
        return const Color(0xFF1F7A4D);
      case OrderStatus.delivered:
        return const Color(0xFF0E3B38);
    }
  }

  Color get pillBackground {
    switch (this) {
      case OrderStatus.pending:
      case OrderStatus.cutting:
        return const Color(0xFFFCF1DC);
      case OrderStatus.stitching:
        return const Color(0xFFE2EFEC);
      case OrderStatus.ready:
        return const Color(0xFFE2F3EA);
      case OrderStatus.delivered:
        return const Color(0xFFE2EFEC);
    }
  }

  /// Mockup labels: Mila · Cutting · Silai · Ready · Diya
  String get shortLabel {
    switch (this) {
      case OrderStatus.pending:
        return "Mila";
      case OrderStatus.cutting:
        return "Cutting";
      case OrderStatus.stitching:
        return "Silai";
      case OrderStatus.ready:
        return "Ready";
      case OrderStatus.delivered:
        return "Diya";
    }
  }

  IconData get icon {
    switch (this) {
      case OrderStatus.pending:
        return Icons.hourglass_empty_rounded;
      case OrderStatus.cutting:
        return Icons.content_cut_rounded;
      case OrderStatus.stitching:
        return Icons.auto_fix_high_rounded;
      case OrderStatus.ready:
        return Icons.check_circle_outline_rounded;
      case OrderStatus.delivered:
        return Icons.local_shipping_rounded;
    }
  }

  OrderStatus? get next {
    final index = OrderStatus.values.indexOf(this);
    if (index < OrderStatus.values.length - 1) {
      return OrderStatus.values[index + 1];
    }
    return null;
  }
}
