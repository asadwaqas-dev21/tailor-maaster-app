// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Darzi';

  @override
  String get dashboard => 'Dashboard';

  @override
  String get customers => 'Customers';

  @override
  String get orders => 'Orders';

  @override
  String get measurements => 'Measurements';

  @override
  String get settings => 'Settings';

  @override
  String get todayDeliveries => 'Today\'s Deliveries';

  @override
  String get pendingOrders => 'Pending Orders';

  @override
  String get totalUnpaid => 'Total Unpaid';

  @override
  String get totalOrders => 'Total Orders';

  @override
  String get recentOrders => 'Recent Orders';

  @override
  String get quickActions => 'Quick Actions';

  @override
  String get addCustomer => 'Add Customer';

  @override
  String get editCustomer => 'Edit Customer';

  @override
  String get customerDetails => 'Customer Details';

  @override
  String get searchCustomers => 'Search customers...';

  @override
  String get noCustomers => 'No customers yet';

  @override
  String get noCustomersSubtitle => 'Add your first customer to get started';

  @override
  String get customerName => 'Customer Name';

  @override
  String get phone => 'Phone';

  @override
  String get email => 'Email';

  @override
  String get invalidEmail => 'Enter a valid email address';

  @override
  String get address => 'Address';

  @override
  String get gender => 'Gender';

  @override
  String get male => 'Male';

  @override
  String get female => 'Female';

  @override
  String get notes => 'Notes';

  @override
  String get orderHistory => 'Order History';

  @override
  String get deleteCustomerConfirm =>
      'Are you sure you want to delete this customer?';

  @override
  String get deleteCustomerMessage =>
      'This action cannot be undone. All related data will be removed.';

  @override
  String get newOrder => 'New Order';

  @override
  String get editOrder => 'Edit Order';

  @override
  String get orderDetails => 'Order Details';

  @override
  String get searchOrders => 'Search orders...';

  @override
  String get noOrders => 'No orders yet';

  @override
  String get noOrdersSubtitle => 'Create your first order';

  @override
  String get selectCustomer => 'Select Customer';

  @override
  String get selectMeasurement => 'Select Measurement';

  @override
  String get garmentType => 'Garment Type';

  @override
  String get fabricDetails => 'Fabric Details';

  @override
  String get designNotes => 'Design Notes';

  @override
  String get quantity => 'Quantity';

  @override
  String get totalAmount => 'Total Amount';

  @override
  String get advanceAmount => 'Advance';

  @override
  String get remainingBalance => 'Remaining Balance';

  @override
  String get orderDate => 'Order Date';

  @override
  String get deliveryDate => 'Delivery Date';

  @override
  String get orderStatus => 'Order Status';

  @override
  String get paymentStatus => 'Payment Status';

  @override
  String get updateStatus => 'Update Status';

  @override
  String get deleteOrderConfirm =>
      'Are you sure you want to delete this order?';

  @override
  String get deleteOrderMessage => 'This action cannot be undone.';

  @override
  String get whatsappReceipt => 'WhatsApp Receipt';

  @override
  String get emailReceipt => 'Email Receipt';

  @override
  String get sendReceipt => 'Send Receipt';

  @override
  String get readyForPickup => 'Ready for Pickup';

  @override
  String get notifyCustomer => 'Notify Customer';

  @override
  String get selectNotificationMethod => 'Select notification method:';

  @override
  String get sendViaWhatsApp => 'Send WhatsApp';

  @override
  String get sendViaEmail => 'Send Email';

  @override
  String get sendViaBoth => 'Send Both';

  @override
  String get smtpSettings => 'SMTP Settings (Automatic Email)';

  @override
  String get smtpHost => 'SMTP Host';

  @override
  String get smtpPort => 'SMTP Port';

  @override
  String get senderEmail => 'Sender Email';

  @override
  String get appPassword => 'App Password';

  @override
  String get sendAutomatically => 'Send Emails Automatically';

  @override
  String get smtpConfigRequired =>
      'Please configure SMTP settings to send automatic emails.';

  @override
  String get emailSentSuccess => 'Email sent successfully!';

  @override
  String emailSendFailed(Object error) {
    return 'Failed to send email: $error';
  }

  @override
  String get phoneExistsError =>
      'A customer with this phone number already exists';

  @override
  String get pending => 'Pending';

  @override
  String get cutting => 'Cutting';

  @override
  String get stitching => 'Stitching';

  @override
  String get ready => 'Ready';

  @override
  String get delivered => 'Delivered';

  @override
  String get paid => 'Paid';

  @override
  String get unpaid => 'Unpaid';

  @override
  String get partial => 'Partial';

  @override
  String get addMeasurement => 'Add Measurement';

  @override
  String get editMeasurement => 'Edit Measurement';

  @override
  String get measurementDetails => 'Measurement Details';

  @override
  String get noMeasurements => 'No measurements yet';

  @override
  String get noMeasurementsSubtitle => 'Add measurements for this customer';

  @override
  String get selectCategory => 'Select Category';

  @override
  String get deleteMeasurementConfirm => 'Delete this measurement?';

  @override
  String get deleteMeasurementMessage => 'This action cannot be undone.';

  @override
  String get photos => 'Photos';

  @override
  String get shalwarKameez => 'Shalwar Kameez';

  @override
  String get mensSuit => 'Men\'s Suit';

  @override
  String get kurta => 'Kurta';

  @override
  String get waistcoat => 'Waistcoat';

  @override
  String get pants => 'Pants';

  @override
  String get shirt => 'Shirt';

  @override
  String get womensDress => 'Women\'s Dress';

  @override
  String get darkMode => 'Dark Mode';

  @override
  String get language => 'Language';

  @override
  String get english => 'English';

  @override
  String get urdu => 'اردو';

  @override
  String get appInfo => 'App Info';

  @override
  String get version => 'Version';

  @override
  String get save => 'Save';

  @override
  String get cancel => 'Cancel';

  @override
  String get delete => 'Delete';

  @override
  String get confirm => 'Confirm';

  @override
  String get edit => 'Edit';

  @override
  String get search => 'Search';

  @override
  String get all => 'All';

  @override
  String get today => 'Today';

  @override
  String get tomorrow => 'Tomorrow';

  @override
  String get overdue => 'Overdue';

  @override
  String get optional => 'Optional';

  @override
  String get customerAdded => 'Customer added successfully';

  @override
  String get customerUpdated => 'Customer updated successfully';

  @override
  String get customerDeleted => 'Customer deleted';

  @override
  String get orderAdded => 'Order created successfully';

  @override
  String get orderUpdated => 'Order updated successfully';

  @override
  String get orderDeleted => 'Order deleted';

  @override
  String get measurementAdded => 'Measurement added successfully';

  @override
  String get measurementUpdated => 'Measurement updated successfully';

  @override
  String get measurementDeleted => 'Measurement deleted';

  @override
  String get statusUpdated => 'Status updated';

  @override
  String get requiredField => 'This field is required';

  @override
  String get invalidPhone => 'Enter a valid phone number';

  @override
  String get invalidAmount => 'Enter a valid amount';

  @override
  String get staff => 'Staff';

  @override
  String get reports => 'Reports';

  @override
  String get printInvoice => 'Print Invoice';

  @override
  String get sharePdf => 'Share PDF';

  @override
  String get salesReport => 'Sales Report';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get paymentRequiredBeforeDelivery =>
      'Customer must pay the full amount before the order can be delivered.';

  @override
  String get notifications => 'Notifications';

  @override
  String get noNotifications => 'No notifications';

  @override
  String get noNotificationsSubtitle => 'You are all caught up!';

  @override
  String get overdueDeliveries => 'Overdue Deliveries';

  @override
  String get dueToday => 'Due Today';

  @override
  String get upcomingDeliveries => 'Upcoming Deliveries';

  @override
  String get overdueReminder => 'Overdue Reminder';

  @override
  String get deliveryDueToday => 'Delivery Due Today';

  @override
  String get upcomingDelivery => 'Upcoming Delivery';

  @override
  String notificationBody(Object garment, Object id, Object name) {
    return 'Order #$id for $name ($garment) is pending delivery.';
  }

  @override
  String get userRole => 'User Role';

  @override
  String get owner => 'Owner';

  @override
  String get stitcher => 'Stitcher';

  @override
  String get selectStitcher => 'Select Stitcher';

  @override
  String get activeProfile => 'Active Profile';

  @override
  String get myWork => 'My Work';

  @override
  String get stitchingCost => 'Stitching Cost';

  @override
  String get isStitcherPaid => 'Stitcher Paid';

  @override
  String get markAsPaid => 'Mark as Paid';

  @override
  String get paymentPending => 'Payment Pending';

  @override
  String get paymentReceived => 'Payment Received';

  @override
  String get completedWork => 'Completed Work';
}
