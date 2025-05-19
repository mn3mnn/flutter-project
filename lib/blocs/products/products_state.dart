import 'package:project_flutter/models/restaurant.dart';
import 'package:project_flutter/models/product.dart';

abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class RestaurantsLoading extends ProductsState {}

class RestaurantsLoaded extends ProductsState {
  final List<Restaurant> restaurants;

  RestaurantsLoaded(this.restaurants);
}

class RestaurantsError extends ProductsState {
  final String message;

  RestaurantsError(this.message);
}

class ProductsLoading extends ProductsState {
  final List<Restaurant> restaurants;
  final int selectedRestaurantId;

  ProductsLoading(this.restaurants, this.selectedRestaurantId);
}

class ProductsLoaded extends ProductsState {
  final List<Restaurant> restaurants;
  final int selectedRestaurantId;
  final List<Product> products;

  ProductsLoaded(this.restaurants, this.selectedRestaurantId, this.products);
}

class ProductsError extends ProductsState {
  final List<Restaurant> restaurants;
  final int selectedRestaurantId;
  final String message;

  ProductsError(this.restaurants, this.selectedRestaurantId, this.message);
}

class ProductSearchLoading extends ProductsState {}

class ProductSearchLoaded extends ProductsState {
  final List<Restaurant> restaurants;

  ProductSearchLoaded(this.restaurants);
}

class ProductSearchError extends ProductsState {
  final String message;

  ProductSearchError(this.message);
}
