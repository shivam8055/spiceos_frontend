class InventoryApiItem {
  final int id;
  final String name;
  final String? sku;
  final String unit;
  final double quantity;
  final double reorderLevel;
  final double costPerUnit;
  final bool isActive;

  const InventoryApiItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.unit,
    required this.quantity,
    required this.reorderLevel,
    required this.costPerUnit,
    required this.isActive,
  });

  factory InventoryApiItem.fromJson(Map<String, dynamic> json) {
    return InventoryApiItem(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String,
      sku: json['sku'] as String?,
      unit: json['unit'] as String? ?? 'unit',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 0,
      reorderLevel: (json['reorder_level'] as num?)?.toDouble() ?? 0,
      costPerUnit: (json['cost_per_unit'] as num?)?.toDouble() ?? 0,
      isActive: json['is_active'] as bool? ?? true,
    );
  }

  bool get isOutOfStock => quantity <= 0;
  bool get isLowStock => !isOutOfStock && quantity <= reorderLevel;
  double get stockValue => quantity * costPerUnit;
}