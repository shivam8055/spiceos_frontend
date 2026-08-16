import 'menu_modifier.dart';

class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.available,
    this.description,
    this.modifiers = const [],
  });

  final int id;
  final String name;
  final String category;
  final double price;
  final bool available;
  final String? description;
  final List<MenuModifier> modifiers;

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'] as int,
        name: json['name'] as String,
        category: json['category'] as String? ?? 'Uncategorized',
        price: (json['price'] as num).toDouble(),
        available: json['available'] as bool? ?? true,
        description: json['description'] as String?,
        modifiers: ((json['modifiers'] ?? json['modifiers_json']) as List<dynamic>? ?? const [])
            .whereType<Map>()
            .map((modifier) => MenuModifier.fromJson(Map<String, dynamic>.from(modifier)))
            .toList(),
      );
}
