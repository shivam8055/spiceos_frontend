class Restaurant {
  const Restaurant({
    required this.restaurantId,
    required this.name,
    required this.active,
    this.logoUrl,
  });

  final String restaurantId;
  final String name;
  final bool active;
  final String? logoUrl;

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      restaurantId: json['restaurant_id'] as String,
      name: json['name'] as String,
      active: json['active'] as bool? ?? false,
      logoUrl: json['logo_url'] as String?,
    );
  }
}
