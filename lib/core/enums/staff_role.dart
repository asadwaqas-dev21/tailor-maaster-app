import "package:flutter/material.dart";
import "package:hive/hive.dart";

part "staff_role.g.dart";

@HiveType(typeId: 4)
enum StaffRole {
  @HiveField(0)
  cutter,
  @HiveField(1)
  stitcher,
  @HiveField(2)
  finisher,
  @HiveField(3)
  delivery
}

extension StaffRoleExtension on StaffRole {
  String get labelEn {
    switch (this) {
      case StaffRole.cutter:
        return "Cutter";
      case StaffRole.stitcher:
        return "Stitcher";
      case StaffRole.finisher:
        return "Finisher";
      case StaffRole.delivery:
        return "Delivery";
    }
  }

  String get labelUr {
    switch (this) {
      case StaffRole.cutter:
        return "کٹائی کرنے والا";
      case StaffRole.stitcher:
        return "سلائی کرنے والا";
      case StaffRole.finisher:
        return "فنشنگ کرنے والا";
      case StaffRole.delivery:
        return "ڈیلیوری کرنے والا";
    }
  }

  Color get color {
    switch (this) {
      case StaffRole.cutter:
        return Colors.orange;
      case StaffRole.stitcher:
        return Colors.blue;
      case StaffRole.finisher:
        return Colors.purple;
      case StaffRole.delivery:
        return Colors.teal;
    }
  }
}
