import 'package:flutter/material.dart';

import '../models/invoice.dart';

class InvoicePreview extends StatelessWidget {
  final Invoice invoice;

  const InvoicePreview({
    super.key,
    required this.invoice,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Spice Box",
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text("Invoice: ${invoice.invoiceNumber}"),
            Text("Customer: ${invoice.customerName}"),
            Text("Phone: ${invoice.phone}"),

            const Divider(),

            Text("Subtotal : ₹${invoice.subtotal.toStringAsFixed(2)}"),
            Text("Discount : ₹${invoice.discount.toStringAsFixed(2)}"),
            Text("GST : ₹${invoice.gst.toStringAsFixed(2)}"),
            Text("Delivery : ₹${invoice.deliveryCharge.toStringAsFixed(2)}"),

            const Divider(),

            Text(
              "Grand Total : ₹${invoice.total.toStringAsFixed(2)}",
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 16),

            Text("Payment : ${invoice.paymentMethod}"),
          ],
        ),
      ),
    );
  }
}