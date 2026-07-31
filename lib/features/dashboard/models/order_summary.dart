class OrderSummary {
  final String orderNo;
  final String customer;
  final String item;
  final String status;
  final double amount;

  const OrderSummary({
    required this.orderNo,
    required this.customer,
    required this.item,
    required this.status,
    required this.amount,
  });
}