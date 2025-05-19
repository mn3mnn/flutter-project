abstract class ProductsEvent {}

class LoadRestaurantsEvent extends ProductsEvent {}

class SelectRestaurantEvent extends ProductsEvent {
  final int restaurantId;

  SelectRestaurantEvent(this.restaurantId);
}

class SearchProductsEvent extends ProductsEvent {
  final String query;

  SearchProductsEvent(this.query);
}
