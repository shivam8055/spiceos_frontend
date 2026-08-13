class InventoryItem {
  final int id;
  final String name;
  final String? sku;
  final String unit;
  final double quantity;
  final double reorderLevel;
  final double costPerUnit;
  final bool isActive;

  const InventoryItem({
    required this.id,
    required this.name,
    required this.sku,
    required this.unit,
    required this.quantity,
    required this.reorderLevel,
    required this.costPerUnit,
    required this.isActive,
  });

  factory InventoryItem.fromJson(Map<String, dynamic> json) {
    return InventoryItem(
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

  bool get isLowStock => quantity <= reorderLevel;
  bool get isOutOfStock => quantity <= 0;
  double get stockValue => quantity * costPerUnit;
}