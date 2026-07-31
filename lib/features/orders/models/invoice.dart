class Invoice {
  final String invoiceNumber;
  final String customerName;
  final String phone;
  final DateTime createdAt;
  final double subtotal;
  final double discount;
  final double gst;
  final double deliveryCharge;
  final double total;
  final String paymentMethod;

  const Invoice({
    required this.invoiceNumber,
    required this.customerName,
    required this.phone,
    required this.createdAt,
    required this.subtotal,
    required this.discount,
    required this.gst,
    required this.deliveryCharge,
    required this.total,
    required this.paymentMethod,
  });
}