extension StringExtensions on String {
  /// Capitalize first letter
  String get capitalize {
    if (isEmpty) return this;
    return "${this[0].toUpperCase()}${substring(1)}";
  }

  /// Format phone number for WhatsApp (add country code if missing)
  String get toWhatsAppNumber {
    String cleaned = replaceAll(RegExp(r"[^\d+]"), "");
    if (cleaned.startsWith("0")) {
      cleaned = "+92${cleaned.substring(1)}";
    }
    if (!cleaned.startsWith("+")) {
      cleaned = "+92$cleaned";
    }
    return cleaned;
  }

  /// Check if string is a valid phone number
  bool get isValidPhone {
    final cleaned = replaceAll(RegExp(r"[^\d]"), "");
    return cleaned.length >= 10 && cleaned.length <= 13;
  }

  /// Truncate with ellipsis
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return "${substring(0, maxLength)}...";
  }

  /// Convert snake_case to Title Case
  String get snakeToTitle {
    return split("_").map((word) => word.capitalize).join(" ");
  }
}
