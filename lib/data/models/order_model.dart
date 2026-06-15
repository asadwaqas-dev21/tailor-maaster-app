import "package:hive/hive.dart";
import "package:tailor_app/core/enums/order_status.dart";
import "package:tailor_app/core/enums/payment_status.dart";
import "package:tailor_app/domain/entities/order.dart";

part "order_model.g.dart";

@HiveType(typeId: 1)
class OrderModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String customerId;

  @HiveField(2)
  final String customerName;

  @HiveField(3)
  final String? measurementId;

  @HiveField(4)
  final String garmentType;

  @HiveField(5)
  final String? fabricDetails;

  @HiveField(6)
  final String? designNotes;

  @HiveField(7)
  final int quantity;

  @HiveField(8)
  final double totalAmount;

  @HiveField(9)
  final double advanceAmount;

  @HiveField(10)
  final OrderStatus status;

  @HiveField(11)
  final PaymentStatus paymentStatus;

  @HiveField(12)
  final DateTime orderDate;

  @HiveField(13)
  final DateTime deliveryDate;

  @HiveField(14)
  final List<String> photoPaths;

  @HiveField(15)
  final DateTime createdAt;

  @HiveField(16)
  final String? assignedStaffId;

  @HiveField(17)
  final String? assignedStaffName;

  OrderModel({
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

  /// Convert to domain entity
  Order toEntity() {
    return Order(
      id: id,
      customerId: customerId,
      customerName: customerName,
      measurementId: measurementId,
      garmentType: garmentType,
      fabricDetails: fabricDetails,
      designNotes: designNotes,
      quantity: quantity,
      totalAmount: totalAmount,
      advanceAmount: advanceAmount,
      status: status,
      paymentStatus: paymentStatus,
      orderDate: orderDate,
      deliveryDate: deliveryDate,
      photoPaths: List<String>.from(photoPaths),
      createdAt: createdAt,
      assignedStaffId: assignedStaffId,
      assignedStaffName: assignedStaffName,
    );
  }

  /// Create from domain entity
  factory OrderModel.fromEntity(Order entity) {
    return OrderModel(
      id: entity.id,
      customerId: entity.customerId,
      customerName: entity.customerName,
      measurementId: entity.measurementId,
      garmentType: entity.garmentType,
      fabricDetails: entity.fabricDetails,
      designNotes: entity.designNotes,
      quantity: entity.quantity,
      totalAmount: entity.totalAmount,
      advanceAmount: entity.advanceAmount,
      status: entity.status,
      paymentStatus: entity.paymentStatus,
      orderDate: entity.orderDate,
      deliveryDate: entity.deliveryDate,
      photoPaths: List<String>.from(entity.photoPaths),
      createdAt: entity.createdAt,
    );
  }
}
