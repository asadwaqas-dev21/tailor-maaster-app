class AppConstants {
  AppConstants._();

  static const String appName = "Darzi";
  static const String appNameUr = "درزی";
  static const String appTagline = "Tailor Studio";
  static const String appVersion = "1.0.0";

  // Currency
  static const String currencySymbol = "Rs";
  static const String currencyCode = "PKR";

  // Notification
  static const int deliveryReminderHour = 9;
  static const int deliveryReminderMinute = 0;
  static const int reminderDaysBefore = 1;

  // Notification Channel
  static const String notificationChannelId = "delivery_reminders";
  static const String notificationChannelName = "Delivery Reminders";
  static const String notificationChannelDesc =
      "Notifications for upcoming order deliveries";

  // WhatsApp
  static const String whatsAppBaseUrl = "https://wa.me/";

  // Search
  static const Duration searchDebounce = Duration(milliseconds: 400);

  // Date formats
  static const String dateFormat = "dd MMM yyyy";
  static const String dateTimeFormat = "dd MMM yyyy, hh:mm a";
}
