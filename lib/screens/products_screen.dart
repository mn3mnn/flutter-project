import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_flutter/blocs/products/products_bloc.dart';
import 'package:project_flutter/blocs/products/products_event.dart';
import 'package:project_flutter/blocs/products/products_state.dart';
import 'package:project_flutter/models/product.dart';
import 'package:project_flutter/models/restaurant.dart';

class ProductsScreen extends StatefulWidget {
  final int? restaurantId;

  const ProductsScreen({Key? key, this.restaurantId}) : super(key: key);

  @override
  _ProductsScreenState createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  @override
  void initState() {
    super.initState();
    context.read<ProductsBloc>().add(LoadRestaurantsEvent());
    if (widget.restaurantId != null) {
      context.read<ProductsBloc>().add(
        SelectRestaurantEvent(widget.restaurantId!),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Restaurant Products'),
        backgroundColor: const Color.fromRGBO(70, 220, 220, 0.773),
      ),
      body: BlocBuilder<ProductsBloc, ProductsState>(
        builder: (context, state) {
          if (state is ProductsInitial || state is RestaurantsLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is RestaurantsError) {
            return Center(child: Text('Error: ${state.message}'));
          } else {
            List<Restaurant> restaurants = [];
            int? selectedRestaurantId;

            if (state is RestaurantsLoaded) {
              restaurants = state.restaurants;
            } else if (state is ProductsLoading) {
              restaurants = state.restaurants;
              selectedRestaurantId = state.selectedRestaurantId;
            } else if (state is ProductsLoaded) {
              restaurants = state.restaurants;
              selectedRestaurantId = state.selectedRestaurantId;
            } else if (state is ProductsError) {
              restaurants = state.restaurants;
              selectedRestaurantId = state.selectedRestaurantId;
            }

            return Column(
              children: [
                Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Color.fromRGBO(70, 220, 220, 0.773),
                        Color.fromRGBO(45, 139, 227, 0.278),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Select a Restaurant:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            isExpanded: true,
                            value: selectedRestaurantId,
                            hint: const Text('Select a restaurant'),
                            items:
                                restaurants
                                    .map(
                                      (restaurant) => DropdownMenuItem(
                                        value: restaurant.id,
                                        child: Text(restaurant.name),
                                      ),
                                    )
                                    .toList(),
                            onChanged: (value) {
                              if (value != null) {
                                context.read<ProductsBloc>().add(
                                  SelectRestaurantEvent(value),
                                );
                              }
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(child: _buildProductsList(state)),
              ],
            );
          }
        },
      ),
    );
  }

  Widget _buildProductsList(ProductsState state) {
    if (state is ProductsLoading) {
      return const Center(child: CircularProgressIndicator());
    } else if (state is ProductsLoaded) {
      final products = state.products;

      if (products.isEmpty) {
        return const Center(
          child: Text('No products available for this restaurant.'),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.75,
        ),
        itemCount: products.length,
        itemBuilder: (context, index) {
          final product = products[index];
          return _buildProductCard(product);
        },
      );
    } else if (state is ProductsError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.red, size: 60),
            const SizedBox(height: 16),
            Text('Error: ${state.message}', textAlign: TextAlign.center),
            ElevatedButton(
              onPressed: () {
                context.read<ProductsBloc>().add(
                  SelectRestaurantEvent(state.selectedRestaurantId),
                );
              },
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    } else {
      return const Center(
        child: Text('Please select a restaurant to view products'),
      );
    }
  }

  Widget _buildProductCard(Product product) {
    return Card(
      elevation: 4,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              color: Colors.grey.shade200,
              child: const Icon(Icons.fastfood, size: 80, color: Colors.grey),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '\$${product.price.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (product.description != null &&
                    product.description!.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    product.description!,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
