import 'package:project_flutter/models/product.dart';

class Restaurant {
  final int id;
  final String name;
  final List<Product> products;
  final double? lat; // Added for map view
  final double? lng; // Added for map view

  Restaurant({
    required this.id,
    required this.name,
    this.products = const [],
    this.lat,
    this.lng,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      products:
          json['products'] != null
              ? List<Product>.from(
                json['products'].map((x) => Product.fromJson(x)),
              )
              : [],
      lat: json['latitude']?.toDouble(),
      lng: json['longtude']?.toDouble(),
    );
  }
}
