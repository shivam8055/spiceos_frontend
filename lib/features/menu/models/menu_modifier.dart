class MenuModifier {
  const MenuModifier({required this.name, required this.price, this.required = false});

  final String name;
  final double price;
  final bool required;

  factory MenuModifier.fromJson(Map<String, dynamic> json) => MenuModifier(
        name: json['name'] as String? ?? '',
        price: (json['price'] as num?)?.toDouble() ?? 0,
        required: json['required'] as bool? ?? false,
      );
}
