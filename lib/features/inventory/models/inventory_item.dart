class InventoryItem {
  final int id;
  final String name;
  final String category;
  final double quantity;
  final String unit;
  final double reorderLevel;
  final double costPrice;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.category,
    required this.quantity,
    required this.unit,
    required this.reorderLevel,
    required this.costPrice,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as int,
      name: json['name'] as String,
      category: json['category'] as String,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      reorderLevel: (json['reorder_level'] as num).toDouble(),
      costPrice: (json['cost_price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'quantity': quantity,
      'unit': unit,
      'reorder_level': reorderLevel,
      'cost_price': costPrice,
    };
  }
}
