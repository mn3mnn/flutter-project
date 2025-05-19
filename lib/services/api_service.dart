// services/api_service.dart
import 'package:dio/dio.dart';
import 'package:project_flutter/models/restaurant.dart';
import 'package:project_flutter/models/product.dart';

class ApiService {
  final Dio _dio = Dio(
    BaseOptions(
      baseUrl: 'http://10.0.2.2:5042/api',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 3),
    ),
  );

  Future<List<Restaurant>> getAllRestaurants() async {
    try {
      final response = await _dio.get('/Restaurant/GetAll');
      return (response.data as List)
          .map(
            (restaurant) =>
                Restaurant(id: restaurant['id'], name: restaurant['name']),
          )
          .toList();
    } catch (e) {
      print('Error getting restaurants: $e');
      return [];
    }
  }

  Future<List<Product>> getRestaurantProducts(int restaurantId) async {
    try {
      final response = await _dio.get('/Restaurant/Products/$restaurantId');
      return (response.data as List)
          .map((product) => Product.fromJson(product))
          .toList();
    } catch (e) {
      print('Error getting restaurant products: $e');
      return [];
    }
  }

  Future<List<Restaurant>> searchProducts(String query) async {
    try {
      final response = await _dio.get(
        '/Product/RestaurantsByProductName/$query',
      );
      return (response.data as List)
          .map((restaurant) => Restaurant.fromJson(restaurant))
          .toList();
    } catch (e) {
      print('Error searching products: $e');
      return [];
    }
  }
}
