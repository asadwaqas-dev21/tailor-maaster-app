import "package:equatable/equatable.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/enums/payment_status.dart";

class Order extends Equatable {
  final String id;
  final String customerId;
  final String customerName;
  final String? measurementId;
  final String garmentType;
  final String? fabricDetails;
  final String? designNotes;
  final int quantity;
  final double totalAmount;
  final double advanceAmount;
  final OrderStatus status;
  final PaymentStatus paymentStatus;
  final DateTime orderDate;
  final DateTime deliveryDate;
  final List<String> photoPaths;
  final DateTime createdAt;
  final String? assignedStaffId;
  final String? assignedStaffName;

  const Order({
    required this.id,
    required this.customerId,
    required this.customerName,
    this.measurementId,
    required this.garmentType,
    this.fabricDetails,
    this.designNotes,
    required this.quantity,
    required this.totalAmount,
    required this.advanceAmount,
    required this.status,
    required this.paymentStatus,
    required this.orderDate,
    required this.deliveryDate,
    this.photoPaths = const [],
    required this.createdAt,
    this.assignedStaffId,
    this.assignedStaffName,
  });

  /// Remaining balance
  double get remainingAmount => totalAmount - advanceAmount;

  Order copyWith({
    String? id,
    String? customerId,
    String? customerName,
    String? measurementId,
    String? garmentType,
    String? fabricDetails,
    String? designNotes,
    int? quantity,
    double? totalAmount,
    double? advanceAmount,
    OrderStatus? status,
    PaymentStatus? paymentStatus,
    DateTime? orderDate,
    DateTime? deliveryDate,
    List<String>? photoPaths,
    DateTime? createdAt,
  }) {
    return Order(
      id: id ?? this.id,
      customerId: customerId ?? this.customerId,
      customerName: customerName ?? this.customerName,
      measurementId: measurementId ?? this.measurementId,
      garmentType: garmentType ?? this.garmentType,
      fabricDetails: fabricDetails ?? this.fabricDetails,
      designNotes: designNotes ?? this.designNotes,
      quantity: quantity ?? this.quantity,
      totalAmount: totalAmount ?? this.totalAmount,
      advanceAmount: advanceAmount ?? this.advanceAmount,
      status: status ?? this.status,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      orderDate: orderDate ?? this.orderDate,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      photoPaths: photoPaths ?? this.photoPaths,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        customerId,
        customerName,
        measurementId,
        garmentType,
        fabricDetails,
        designNotes,
        quantity,
        totalAmount,
        advanceAmount,
        status,
        paymentStatus,
        orderDate,
        deliveryDate,
        photoPaths,
        createdAt,
        assignedStaffId,
        assignedStaffName,
      ];
}
