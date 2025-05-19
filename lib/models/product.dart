class Product {
  final int id;
  final String name;
  final double price;
  final String? description;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.description,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['name'],
      price:
          json['price'] != null ? double.parse(json['price'].toString()) : 0.0,
      description: json['description'],
    );
  }
}
