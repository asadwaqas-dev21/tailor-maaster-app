// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Urdu (`ur`).
class AppLocalizationsUr extends AppLocalizations {
  AppLocalizationsUr([String locale = 'ur']) : super(locale);

  @override
  String get appName => 'درزی';

  @override
  String get dashboard => 'ڈیش بورڈ';

  @override
  String get customers => 'گاہک';

  @override
  String get orders => 'آرڈرز';

  @override
  String get measurements => 'پیمائش';

  @override
  String get settings => 'ترتیبات';

  @override
  String get todayDeliveries => 'آج کی ڈیلیوریز';

  @override
  String get pendingOrders => 'زیر التوا آرڈرز';

  @override
  String get totalUnpaid => 'کل بقایا';

  @override
  String get totalOrders => 'کل آرڈرز';

  @override
  String get recentOrders => 'حالیہ آرڈرز';

  @override
  String get quickActions => 'فوری کارروائی';

  @override
  String get addCustomer => 'گاہک شامل کریں';

  @override
  String get editCustomer => 'گاہک میں ترمیم';

  @override
  String get customerDetails => 'گاہک کی تفصیلات';

  @override
  String get searchCustomers => 'گاہک تلاش کریں...';

  @override
  String get noCustomers => 'ابھی تک کوئی گاہک نہیں';

  @override
  String get noCustomersSubtitle => 'شروع کرنے کے لیے اپنا پہلا گاہک شامل کریں';

  @override
  String get customerName => 'گاہک کا نام';

  @override
  String get phone => 'فون';

  @override
  String get email => 'ای میل';

  @override
  String get invalidEmail => 'درست ای میل درج کریں';

  @override
  String get address => 'پتہ';

  @override
  String get gender => 'جنس';

  @override
  String get male => 'مرد';

  @override
  String get female => 'عورت';

  @override
  String get notes => 'نوٹس';

  @override
  String get orderHistory => 'آرڈر کی تاریخ';

  @override
  String get deleteCustomerConfirm =>
      'کیا آپ واقعی اس گاہک کو حذف کرنا چاہتے ہیں؟';

  @override
  String get deleteCustomerMessage =>
      'یہ عمل واپس نہیں ہو سکتا۔ تمام متعلقہ ڈیٹا ہٹا دیا جائے گا۔';

  @override
  String get newOrder => 'نیا آرڈر';

  @override
  String get editOrder => 'آرڈر میں ترمیم';

  @override
  String get orderDetails => 'آرڈر کی تفصیلات';

  @override
  String get searchOrders => 'آرڈر تلاش کریں...';

  @override
  String get noOrders => 'ابھی تک کوئی آرڈر نہیں';

  @override
  String get noOrdersSubtitle => 'اپنا پہلا آرڈر بنائیں';

  @override
  String get selectCustomer => 'گاہک منتخب کریں';

  @override
  String get selectMeasurement => 'پیمائش منتخب کریں';

  @override
  String get garmentType => 'لباس کی قسم';

  @override
  String get fabricDetails => 'کپڑے کی تفصیلات';

  @override
  String get designNotes => 'ڈیزائن نوٹس';

  @override
  String get quantity => 'مقدار';

  @override
  String get totalAmount => 'کل رقم';

  @override
  String get advanceAmount => 'پیشگی';

  @override
  String get remainingBalance => 'باقی رقم';

  @override
  String get orderDate => 'آرڈر کی تاریخ';

  @override
  String get deliveryDate => 'ڈیلیوری کی تاریخ';

  @override
  String get orderStatus => 'آرڈر کی حیثیت';

  @override
  String get paymentStatus => 'ادائیگی کی حیثیت';

  @override
  String get updateStatus => 'حیثیت اپ ڈیٹ کریں';

  @override
  String get deleteOrderConfirm =>
      'کیا آپ واقعی اس آرڈر کو حذف کرنا چاہتے ہیں؟';

  @override
  String get deleteOrderMessage => 'یہ عمل واپس نہیں ہو سکتا۔';

  @override
  String get whatsappReceipt => 'واٹس ایپ رسید';

  @override
  String get emailReceipt => 'ای میل رسید';

  @override
  String get sendReceipt => 'رسید بھیجیں';

  @override
  String get readyForPickup => 'تیار برائے حوالگی';

  @override
  String get notifyCustomer => 'گاہک کو اطلاع دیں';

  @override
  String get selectNotificationMethod => 'اطلاع دینے کا طریقہ منتخب کریں:';

  @override
  String get sendViaWhatsApp => 'واٹس ایپ بھیجیں';

  @override
  String get sendViaEmail => 'ای میل بھیجیں';

  @override
  String get sendViaBoth => 'دونوں بھیجیں';

  @override
  String get smtpSettings => 'ای میل کی خودکار ترتیبات';

  @override
  String get smtpHost => 'میزبانی سرور (SMTP Host)';

  @override
  String get smtpPort => 'پورٹ (SMTP Port)';

  @override
  String get senderEmail => 'بھیجنے والے کا ای میل';

  @override
  String get appPassword => 'ایپ پاس ورڈ';

  @override
  String get sendAutomatically => 'ای میلز خود بخود بھیجیں';

  @override
  String get smtpConfigRequired =>
      'خودکار ای میلز کے لیے براہ کرم ای میل ترتیبات سیٹ کریں۔';

  @override
  String get emailSentSuccess => 'ای میل کامیابی سے بھیج دی گئی ہے!';

  @override
  String emailSendFailed(Object error) {
    return 'ای میل بھیجنے میں ناکامی: $error';
  }

  @override
  String get phoneExistsError => 'اس فون نمبر کا گاہک پہلے سے موجود ہے';

  @override
  String get pending => 'زیر التوا';

  @override
  String get cutting => 'کٹائی';

  @override
  String get stitching => 'سلائی';

  @override
  String get ready => 'تیار';

  @override
  String get delivered => 'ڈیلیور';

  @override
  String get paid => 'ادا شدہ';

  @override
  String get unpaid => 'غیر ادا شدہ';

  @override
  String get partial => 'جزوی';

  @override
  String get addMeasurement => 'پیمائش شامل کریں';

  @override
  String get editMeasurement => 'پیمائش میں ترمیم';

  @override
  String get measurementDetails => 'پیمائش کی تفصیلات';

  @override
  String get noMeasurements => 'ابھی تک کوئی پیمائش نہیں';

  @override
  String get noMeasurementsSubtitle => 'اس گاہک کے لیے پیمائش شامل کریں';

  @override
  String get selectCategory => 'زمرہ منتخب کریں';

  @override
  String get deleteMeasurementConfirm => 'یہ پیمائش حذف کریں؟';

  @override
  String get deleteMeasurementMessage => 'یہ عمل واپس نہیں ہو سکتا۔';

  @override
  String get photos => 'تصاویر';

  @override
  String get shalwarKameez => 'شلوار قمیض';

  @override
  String get mensSuit => 'مردانہ سوٹ';

  @override
  String get kurta => 'کرتا';

  @override
  String get waistcoat => 'واسکٹ';

  @override
  String get pants => 'پتلون';

  @override
  String get shirt => 'شرٹ';

  @override
  String get womensDress => 'خواتین لباس';

  @override
  String get darkMode => 'ڈارک موڈ';

  @override
  String get language => 'زبان';

  @override
  String get english => 'English';

  @override
  String get urdu => 'اردو';

  @override
  String get appInfo => 'ایپ کی معلومات';

  @override
  String get version => 'ورژن';

  @override
  String get save => 'محفوظ کریں';

  @override
  String get cancel => 'منسوخ';

  @override
  String get delete => 'حذف کریں';

  @override
  String get confirm => 'تصدیق';

  @override
  String get edit => 'ترمیم';

  @override
  String get search => 'تلاش';

  @override
  String get all => 'سب';

  @override
  String get today => 'آج';

  @override
  String get tomorrow => 'کل';

  @override
  String get overdue => 'تاخیر';

  @override
  String get optional => 'اختیاری';

  @override
  String get customerAdded => 'گاہک کامیابی سے شامل ہو گیا';

  @override
  String get customerUpdated => 'گاہک کامیابی سے اپ ڈیٹ ہو گیا';

  @override
  String get customerDeleted => 'گاہک حذف ہو گیا';

  @override
  String get orderAdded => 'آرڈر کامیابی سے بنایا گیا';

  @override
  String get orderUpdated => 'آرڈر کامیابی سے اپ ڈیٹ ہو گیا';

  @override
  String get orderDeleted => 'آرڈر حذف ہو گیا';

  @override
  String get measurementAdded => 'پیمائش کامیابی سے شامل ہو گئی';

  @override
  String get measurementUpdated => 'پیمائش کامیابی سے اپ ڈیٹ ہو گئی';

  @override
  String get measurementDeleted => 'پیمائش حذف ہو گئی';

  @override
  String get statusUpdated => 'حیثیت اپ ڈیٹ ہو گئی';

  @override
  String get requiredField => 'یہ فیلڈ ضروری ہے';

  @override
  String get invalidPhone => 'درست فون نمبر درج کریں';

  @override
  String get invalidAmount => 'درست رقم درج کریں';

  @override
  String get staff => 'عملہ';

  @override
  String get reports => 'رپورٹس';

  @override
  String get printInvoice => 'رسید پرنٹ کریں';

  @override
  String get sharePdf => 'پی ڈی ایف شیئر کریں';

  @override
  String get salesReport => 'سیلز رپورٹ';

  @override
  String get daily => 'روزانہ';

  @override
  String get weekly => 'ہفتہ وار';

  @override
  String get monthly => 'ماہانہ';

  @override
  String get paymentRequiredBeforeDelivery =>
      'آرڈر ڈیلیور کرنے سے پہلے گاہک کو پوری رقم ادا کرنی ہوگی۔';

  @override
  String get notifications => 'نوٹیفیکیشنز';

  @override
  String get noNotifications => 'کوئی نوٹیفکیشن نہیں';

  @override
  String get noNotificationsSubtitle => 'سب کچھ اپ ٹو ڈیٹ ہے!';

  @override
  String get overdueDeliveries => 'تاخیر شدہ ڈیلیوریز';

  @override
  String get dueToday => 'آج ڈیلیور کرنا ہے';

  @override
  String get upcomingDeliveries => 'آنے والی ڈیلیوریز';

  @override
  String get overdueReminder => 'تاخیر کا ریمائنڈر';

  @override
  String get deliveryDueToday => 'آج ڈیلیوری ہونی ہے';

  @override
  String get upcomingDelivery => 'آنے والی ڈیلیوری';

  @override
  String notificationBody(Object garment, Object id, Object name) {
    return 'گاہک $name کا آرڈر #$id ($garment) ڈیلیوری کے لیے زیر التوا ہے۔';
  }

  @override
  String get userRole => 'صارف کا کردار';

  @override
  String get owner => 'مالک';

  @override
  String get stitcher => 'کاریگر';

  @override
  String get selectStitcher => 'کاریگر منتخب کریں';

  @override
  String get activeProfile => 'فعال پروفائل';

  @override
  String get myWork => 'میرا کام';

  @override
  String get stitchingCost => 'سلائی کی اجرت';

  @override
  String get isStitcherPaid => 'اجرت ادا ہو گئی';

  @override
  String get markAsPaid => 'ادائیگی مارک کریں';

  @override
  String get paymentPending => 'بقایا اجرت';

  @override
  String get paymentReceived => 'وصول شدہ اجرت';

  @override
  String get completedWork => 'مکمل شدہ کام';
}
