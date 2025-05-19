import 'package:bloc/bloc.dart';
import 'package:project_flutter/blocs/products/products_event.dart';
import 'package:project_flutter/blocs/products/products_state.dart';
import 'package:project_flutter/services/api_service.dart';

class ProductsBloc extends Bloc<ProductsEvent, ProductsState> {
  final ApiService _apiService = ApiService();

  ProductsBloc() : super(ProductsInitial()) {
    on<LoadRestaurantsEvent>(_onLoadRestaurants);
    on<SelectRestaurantEvent>(_onSelectRestaurant);
    on<SearchProductsEvent>(_onSearchProducts);
  }

  Future<void> _onLoadRestaurants(
    LoadRestaurantsEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(RestaurantsLoading());

    try {
      final restaurants = await _apiService.getAllRestaurants();
      emit(RestaurantsLoaded(restaurants));
    } catch (e) {
      emit(RestaurantsError('Failed to load restaurants: $e'));
    }
  }

  Future<void> _onSelectRestaurant(
    SelectRestaurantEvent event,
    Emitter<ProductsState> emit,
  ) async {
    if (state is RestaurantsLoaded) {
      final currentState = state as RestaurantsLoaded;
      emit(ProductsLoading(currentState.restaurants, event.restaurantId));

      try {
        final products = await _apiService.getRestaurantProducts(
          event.restaurantId,
        );
        emit(
          ProductsLoaded(
            currentState.restaurants,
            event.restaurantId,
            products,
          ),
        );
      } catch (e) {
        emit(
          ProductsError(
            currentState.restaurants,
            event.restaurantId,
            'Failed to load products: $e',
          ),
        );
      }
    } else if (state is ProductsLoaded) {
      final currentState = state as ProductsLoaded;
      emit(ProductsLoading(currentState.restaurants, event.restaurantId));

      try {
        final products = await _apiService.getRestaurantProducts(
          event.restaurantId,
        );
        emit(
          ProductsLoaded(
            currentState.restaurants,
            event.restaurantId,
            products,
          ),
        );
      } catch (e) {
        emit(
          ProductsError(
            currentState.restaurants,
            event.restaurantId,
            'Failed to load products: $e',
          ),
        );
      }
    }
  }

  Future<void> _onSearchProducts(
    SearchProductsEvent event,
    Emitter<ProductsState> emit,
  ) async {
    emit(ProductSearchLoading());

    try {
      final restaurants = await _apiService.searchProducts(event.query);
      emit(ProductSearchLoaded(restaurants));
    } catch (e) {
      emit(ProductSearchError('Failed to search products: $e'));
    }
  }
}
