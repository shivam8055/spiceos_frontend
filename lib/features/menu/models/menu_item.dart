class MenuItem {
  const MenuItem({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.available,
    this.description,
  });

  final int id;
  final String name;
  final String category;
  final double price;
  final bool available;
  final String? description;

  factory MenuItem.fromJson(Map<String, dynamic> json) => MenuItem(
        id: json['id'] as int,
        name: json['name'] as String,
        category: json['category'] as String? ?? 'Uncategorized',
        price: (json['price'] as num).toDouble(),
        available: json['available'] as bool? ?? true,
        description: json['description'] as String?,
      );
}
