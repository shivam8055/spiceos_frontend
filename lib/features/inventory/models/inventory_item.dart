class InventoryItem {
  final int id;
  final String name;
  final String? sku;
  final double quantity;
  final String unit;
  final double reorderLevel;
  final double costPerUnit;
  final bool isActive;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.quantity,
    required this.unit,
    required this.reorderLevel,
    required this.costPerUnit,
    required this.isActive,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
      id: json['id'] as int,
      name: json['name'] as String,
      sku: json['sku'] as String?,
      quantity: (json['quantity'] as num).toDouble(),
      unit: json['unit'] as String,
      reorderLevel: (json['reorder_level'] as num).toDouble(),
      costPerUnit: (json['cost_per_unit'] as num).toDouble(),
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'name': name,
      'sku': sku,
      'unit': unit,
      'quantity': quantity,
      'reorder_level': reorderLevel,
      'cost_per_unit': costPerUnit,
    };
  }
}
