import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:project_flutter/blocs/products/products_bloc.dart';
import 'package:project_flutter/blocs/products/products_event.dart';
import 'package:project_flutter/blocs/products/products_state.dart';
import 'package:project_flutter/models/restaurant.dart';

class ProductSearchScreen extends StatefulWidget {
  const ProductSearchScreen({Key? key}) : super(key: key);

  @override
  _ProductSearchScreenState createState() => _ProductSearchScreenState();
}

class _ProductSearchScreenState extends State<ProductSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _isMapView = false;
  GoogleMapController? _mapController;

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: 'Search for a product...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 14,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    if (_searchController.text.isNotEmpty) {
                      context.read<ProductsBloc>().add(
                        SearchProductsEvent(_searchController.text),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color.fromRGBO(70, 220, 220, 0.773),
                  ),
                  child: const Text('Search'),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  icon: Icon(_isMapView ? Icons.list : Icons.map),
                  label: Text(_isMapView ? 'List View' : 'Map View'),
                  onPressed: () {
                    setState(() {
                      _isMapView = !_isMapView;
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: BlocBuilder<ProductsBloc, ProductsState>(
              builder: (context, state) {
                if (state is ProductSearchLoading) {
                  return const Center(child: CircularProgressIndicator());
                } else if (state is ProductSearchError) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          color: Colors.red,
                          size: 60,
                        ),
                        const SizedBox(height: 16),
                        Text('Error: ${state.message}'),
                        ElevatedButton(
                          onPressed: () {
                            context.read<ProductsBloc>().add(
                              SearchProductsEvent(_searchController.text),
                            );
                          },
                          child: const Text('Retry'),
                        ),
                      ],
                    ),
                  );
                } else if (state is ProductSearchLoaded) {
                  final restaurants = state.restaurants;
                  if (restaurants.isEmpty) {
                    return const Center(
                      child: Text('No restaurants found for this product.'),
                    );
                  }

                  if (_isMapView) {
                    return _buildMapView(restaurants);
                  } else {
                    return _buildListView(restaurants);
                  }
                }
                return const Center(
                  child: Text('Enter a product name to search.'),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListView(List<Restaurant> restaurants) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: restaurants.length,
      itemBuilder: (context, index) {
        final restaurant = restaurants[index];
        return Card(
          elevation: 4,
          margin: const EdgeInsets.only(bottom: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              restaurant.name,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            leading: const Icon(
              Icons.restaurant,
              color: Color.fromARGB(197, 8, 165, 165),
            ),
            onTap: () {
              Navigator.pushNamed(
                context,
                '/products',
                arguments: restaurant.id,
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildMapView(List<Restaurant> restaurants) {
    final markers =
        restaurants
            .where((r) => r.lat != null && r.lng != null)
            .map(
              (restaurant) => Marker(
                markerId: MarkerId(restaurant.id.toString()),
                position: LatLng(restaurant.lat!, restaurant.lng!),
                infoWindow: InfoWindow(title: restaurant.name),
                onTap: () {
                  Navigator.pushNamed(
                    context,
                    '/products',
                    arguments: restaurant.id,
                  );
                },
              ),
            )
            .toSet();

    return GoogleMap(
      initialCameraPosition: CameraPosition(
        target:
            restaurants.isNotEmpty && restaurants[0].lat != null
                ? LatLng(restaurants[0].lat!, restaurants[0].lng!)
                : const LatLng(37.7749, -122.4194), // Default: San Francisco
        zoom: 12,
      ),
      markers: markers,
      onMapCreated: (controller) {
        _mapController = controller;
      },
    );
  }
}
