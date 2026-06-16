import "package:flutter/services.dart";
import "package:pdf/pdf.dart";
import "package:pdf/widgets.dart" as pw;
import "package:printing/printing.dart";
import "package:tailor_app/core/constants/app_constants.dart";
import "package:tailor_app/core/extensions/date_extensions.dart";
import "package:tailor_app/domain/entities/order.dart";

class PdfService {
  PdfService._();

  static Future<void> printInvoice(Order order) async {
    final pdfBytes = await _generateInvoice(order);
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdfBytes,
      name: "Invoice_${order.id.substring(0, 8)}.pdf",
    );
  }

  static Future<void> shareInvoice(Order order) async {
    final pdfBytes = await _generateInvoice(order);
    await Printing.sharePdf(
      bytes: pdfBytes,
      filename: "Invoice_${order.id.substring(0, 8)}.pdf",
    );
  }

  static Future<Uint8List> _generateInvoice(Order order) async {
    final pdf = pw.Document();

    final ttf = await PdfGoogleFonts.interRegular();
    final ttfBold = await PdfGoogleFonts.interBold();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              _buildHeader(ttfBold, ttf),
              pw.SizedBox(height: 20),
              _buildCustomerInfo(order, ttfBold, ttf),
              pw.SizedBox(height: 20),
              _buildOrderDetails(order, ttfBold, ttf),
              pw.SizedBox(height: 20),
              _buildPaymentSummary(order, ttfBold, ttf),
              pw.Spacer(),
              _buildFooter(ttf),
            ],
          );
        },
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildHeader(pw.Font ttfBold, pw.Font ttf) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              AppConstants.appName,
              style: pw.TextStyle(
                font: ttfBold,
                fontSize: 24,
                color: PdfColors.indigo900,
              ),
            ),
            pw.Text(
              "Professional Tailor Management",
              style: pw.TextStyle(
                font: ttf,
                fontSize: 12,
                color: PdfColors.grey700,
              ),
            ),
          ],
        ),
        pw.Text(
          "INVOICE",
          style: pw.TextStyle(
            font: ttfBold,
            fontSize: 24,
            color: PdfColors.grey800,
          ),
        ),
      ],
    );
  }

  static pw.Widget _buildCustomerInfo(
    Order order,
    pw.Font ttfBold,
    pw.Font ttf,
  ) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey100,
        borderRadius: const pw.BorderRadius.all(pw.Radius.circular(8)),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Billed To:",
                style: pw.TextStyle(font: ttfBold, fontSize: 12),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                order.customerName,
                style: pw.TextStyle(font: ttf, fontSize: 14),
              ),
            ],
          ),
          pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.end,
            children: [
              pw.Text(
                "Order Date: ${order.orderDate.formatted}",
                style: pw.TextStyle(font: ttf, fontSize: 12),
              ),
              pw.SizedBox(height: 4),
              pw.Text(
                "Delivery Date: ${order.deliveryDate.formatted}",
                style: pw.TextStyle(font: ttfBold, fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildOrderDetails(
    Order order,
    pw.Font ttfBold,
    pw.Font ttf,
  ) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          "Order Details",
          style: pw.TextStyle(font: ttfBold, fontSize: 16),
        ),
        pw.SizedBox(height: 8),
        pw.TableHelper.fromTextArray(
          headers: ["Item", "Fabric/Notes", "Qty"],
          data: [
            [
              order.garmentType.replaceAll("_", " ").toUpperCase(),
              "${order.fabricDetails ?? ''}\n${order.designNotes ?? ''}".trim(),
              "${order.quantity}",
            ],
          ],
          headerStyle: pw.TextStyle(
            font: ttfBold,
            fontSize: 12,
            color: PdfColors.white,
          ),
          headerDecoration: const pw.BoxDecoration(color: PdfColors.indigo900),
          cellStyle: pw.TextStyle(font: ttf, fontSize: 12),
          cellAlignment: pw.Alignment.centerLeft,
        ),
      ],
    );
  }

  static pw.Widget _buildPaymentSummary(
    Order order,
    pw.Font ttfBold,
    pw.Font ttf,
  ) {
    return pw.Container(
      alignment: pw.Alignment.centerRight,
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.end,
        children: [
          _summaryRow("Total Amount:", order.totalAmount, ttfBold, ttf),
          _summaryRow("Advance Paid:", order.advanceAmount, ttfBold, ttf),
          pw.Container(width: 200, child: pw.Divider()),
          _summaryRow(
            "Remaining Balance:",
            order.remainingAmount,
            ttfBold,
            ttf,
            isTotal: true,
          ),
          pw.SizedBox(height: 8),
          pw.Text(
            "Status: ${order.paymentStatus.name.toUpperCase()}",
            style: pw.TextStyle(
              font: ttfBold,
              fontSize: 12,
              color: order.remainingAmount > 0
                  ? PdfColors.red
                  : PdfColors.green,
            ),
          ),
        ],
      ),
    );
  }

  static pw.Widget _summaryRow(
    String label,
    double amount,
    pw.Font ttfBold,
    pw.Font ttf, {
    bool isTotal = false,
  }) {
    return pw.Container(
      width: 200,
      padding: const pw.EdgeInsets.symmetric(vertical: 4),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          pw.Text(
            label,
            style: pw.TextStyle(font: isTotal ? ttfBold : ttf, fontSize: 12),
          ),
          pw.Text(
            "${AppConstants.currencySymbol} ${amount.toStringAsFixed(0)}",
            style: pw.TextStyle(font: isTotal ? ttfBold : ttf, fontSize: 12),
          ),
        ],
      ),
    );
  }

  static pw.Widget _buildFooter(pw.Font ttf) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.center,
      children: [
        pw.Divider(),
        pw.SizedBox(height: 8),
        pw.Text(
          "Thank you for your Order",
          style: pw.TextStyle(font: ttf, fontSize: 14),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          "Powered by TailorPro",
          style: pw.TextStyle(font: ttf, fontSize: 10, color: PdfColors.grey),
        ),
      ],
    );
  }
}
