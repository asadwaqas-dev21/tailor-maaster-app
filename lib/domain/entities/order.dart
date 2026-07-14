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
  final double stitchingCost;
  final bool isStitcherPaid;
  /// Slip token e.g. DZ-1042 (Supabase: orders.token_code)
  final String tokenCode;
  /// Rush / Eid / shaadi flag (Supabase: orders.is_rush)
  final bool isRush;

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
    this.stitchingCost = 0.0,
    this.isStitcherPaid = false,
    this.tokenCode = "",
    this.isRush = false,
  });

  double get remainingAmount => totalAmount - advanceAmount;

  String get displayToken =>
      tokenCode.isNotEmpty ? tokenCode : "DZ-${1000 + (id.hashCode.abs() % 9000)}";

  String get garmentTitle {
    final g = garmentType.replaceAll("_", " ");
    final note = designNotes?.trim();
    if (note != null && note.isNotEmpty) {
      final short = note.length > 24 ? "${note.substring(0, 24)}…" : note;
      return "$g · $short";
    }
    if (quantity > 1) return "$g · $quantity pcs";
    return g;
  }

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
    String? assignedStaffId,
    String? assignedStaffName,
    double? stitchingCost,
    bool? isStitcherPaid,
    String? tokenCode,
    bool? isRush,
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
      assignedStaffId: assignedStaffId ?? this.assignedStaffId,
      assignedStaffName: assignedStaffName ?? this.assignedStaffName,
      stitchingCost: stitchingCost ?? this.stitchingCost,
      isStitcherPaid: isStitcherPaid ?? this.isStitcherPaid,
      tokenCode: tokenCode ?? this.tokenCode,
      isRush: isRush ?? this.isRush,
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
        stitchingCost,
        isStitcherPaid,
        tokenCode,
        isRush,
      ];
}
