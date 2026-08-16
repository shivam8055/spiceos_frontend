class QRModifier {
  final String id;
  final String name;
  final double priceDelta;
  final bool available;

  const QRModifier({required this.id, required this.name, required this.priceDelta, required this.available});

  factory QRModifier.fromJson(Map<String, dynamic> json) => QRModifier(
        id: json['id'].toString(),
        name: json['name']?.toString() ?? '',
        priceDelta: (json['price_delta'] as num?)?.toDouble() ?? 0,
        available: json['available'] as bool? ?? true,
      );
}

class QRMenuItem {
  final int id;
  final String category;
  final String name;
  final String? description;
  final double price;
  final bool available;
  final List<QRModifier> modifiers;

  const QRMenuItem({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    required this.available,
    required this.modifiers,
  });

  factory QRMenuItem.fromJson(Map<String, dynamic> json) => QRMenuItem(
        id: json['id'] as int,
        category: json['category']?.toString() ?? 'Menu',
        name: json['name']?.toString() ?? '',
        description: json['description']?.toString(),
        price: (json['price'] as num?)?.toDouble() ?? 0,
        available: json['available'] as bool? ?? true,
        modifiers: (json['modifiers'] as List<dynamic>? ?? [])
            .map((e) => QRModifier.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class QRMenu {
  final String restaurantId;
  final String branchId;
  final String tableId;
  final String tableName;
  final String sessionId;
  final List<String> categories;
  final List<QRMenuItem> items;

  const QRMenu({
    required this.restaurantId,
    required this.branchId,
    required this.tableId,
    required this.tableName,
    required this.sessionId,
    required this.categories,
    required this.items,
  });

  factory QRMenu.fromJson(Map<String, dynamic> json) {
    final context = json['context'] as Map<String, dynamic>;
    return QRMenu(
      restaurantId: context['restaurant_id'].toString(),
      branchId: context['branch_id'].toString(),
      tableId: context['table_id'].toString(),
      tableName: context['table_name']?.toString() ?? 'Table',
      sessionId: context['session_id'].toString(),
      categories: (json['categories'] as List<dynamic>? ?? []).map((e) => e.toString()).toList(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => QRMenuItem.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class QRCartLine {
  final QRMenuItem item;
  final int quantity;
  final List<QRModifier> modifiers;
  final String note;

  const QRCartLine({required this.item, required this.quantity, required this.modifiers, this.note = ''});

  double get unitPrice => item.price + modifiers.fold<double>(0, (sum, modifier) => sum + modifier.priceDelta);
  double get total => unitPrice * quantity;

  QRCartLine copyWith({int? quantity, List<QRModifier>? modifiers, String? note}) => QRCartLine(
        item: item,
        quantity: quantity ?? this.quantity,
        modifiers: modifiers ?? this.modifiers,
        note: note ?? this.note,
      );
}
