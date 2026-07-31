import '../models/invoice.dart';

class InvoiceService {
  static String generateInvoiceNumber() {
    final now = DateTime.now();

    return "INV-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-${now.millisecondsSinceEpoch}";
  }

  Invoice createInvoice({
    required String customerName,
    required String phone,
    required double subtotal,
    required double discount,
    required double gst,
    required double deliveryCharge,
    required double total,
    required String paymentMethod,
  }) {
    return Invoice(
      invoiceNumber: generateInvoiceNumber(),
      customerName: customerName,
      phone: phone,
      createdAt: DateTime.now(),
      subtotal: subtotal,
      discount: discount,
      gst: gst,
      deliveryCharge: deliveryCharge,
      total: total,
      paymentMethod: paymentMethod,
    );
  }
}