class OrderPricing {
  final double subtotal;
  final double discount;
  final double deliveryCharge;
  final double gst;

  const OrderPricing({
    required this.subtotal,
    required this.discount,
    required this.deliveryCharge,
    required this.gst,
  });

  double get grandTotal =>
      subtotal - discount + deliveryCharge + gst;
}