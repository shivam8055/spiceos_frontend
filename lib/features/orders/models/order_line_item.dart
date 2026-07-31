class OrderLineItem {
  final String id;
  final String name;
  final double price;
  int quantity;

  OrderLineItem({
    required this.id,
    required this.name,
    required this.price,
    this.quantity = 1,
  });

  double get total => price * quantity;
}