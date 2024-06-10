class Restaurant {
  final int id;
  final String name;
  final String urlPhoto;
  final String description;
  final String priceRange;
  final String location;
  final String address;
  final String type;
  final String urlMenu;
  final double? rating;

  Restaurant({
    required this.id,
    required this.name,
    required this.urlPhoto,
    required this.description,
    required this.priceRange,
    required this.location,
    required this.address,
    required this.type,
    required this.urlMenu,
    this.rating,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      urlPhoto: json['url_photo'],
      description: json['description'] ?? '',
      priceRange: json['price_range'],
      location: json['location'],
      address: json['address'],
      type: json['type'],
      urlMenu: json['url_menu'],
      rating: json['rating'] != null ? double.tryParse(json['rating'].toString()) : null,
    );
  }
}
