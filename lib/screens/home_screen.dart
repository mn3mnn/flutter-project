import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../services/auth_service.dart';
import '../blocs/products/products_bloc.dart';
import '../blocs/products/products_event.dart';
import '../blocs/products/products_state.dart';
import '../models/restaurant.dart';
import 'login_screen.dart';
import 'products_screen.dart';
import 'product_search_screen.dart';

class HomeScreen extends StatefulWidget {
  final String? token;

  const HomeScreen({super.key, this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;

  Future<void> _logout() async {
    await AuthService.removeToken();
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
      (route) => false,
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> _screens = [
      _buildRestaurantsTab(),
      const ProductSearchScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Home'),
        backgroundColor: const Color.fromRGBO(70, 220, 220, 0.773),
        actions: [
          IconButton(icon: const Icon(Icons.logout), onPressed: _logout),
        ],
      ),
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: 'Restaurants',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Products'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(70, 220, 220, 0.773),
        onTap: _onItemTapped,
      ),
    );
  }

  Widget _buildRestaurantsTab() {
    return BlocBuilder<ProductsBloc, ProductsState>(
      builder: (context, state) {
        if (state is RestaurantsLoading) {
          return const Center(child: CircularProgressIndicator());
        } else if (state is RestaurantsError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${state.message}'),
                ElevatedButton(
                  onPressed:
                      () => context.read<ProductsBloc>().add(
                        LoadRestaurantsEvent(),
                      ),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        } else if (state is RestaurantsLoaded) {
          final restaurants = state.restaurants;
          if (restaurants.isEmpty) {
            return const Center(child: Text('No restaurants found.'));
          }
          return _buildRestaurantsGrid(restaurants);
        } else {
          context.read<ProductsBloc>().add(LoadRestaurantsEvent());
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }

  Widget _buildRestaurantsGrid(List<Restaurant> restaurants) {
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProductsBloc>().add(LoadRestaurantsEvent());
      },
      child: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 1,
        ),
        itemCount: restaurants.length,
        itemBuilder: (context, index) {
          final restaurant = restaurants[index];
          return _buildRestaurantCard(restaurant);
        },
      ),
    );
  }

  Widget _buildRestaurantCard(Restaurant restaurant) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProductsScreen(restaurantId: restaurant.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                width: double.infinity,
                color: const Color.fromARGB(255, 212, 233, 238),
                child:
                    restaurant.lat != null && restaurant.lng != null
                        ? Image.network(
                          'https://via.placeholder.com/150', // Replace with actual image if available
                          fit: BoxFit.cover,
                          errorBuilder:
                              (context, error, stackTrace) => const Icon(
                                Icons.restaurant,
                                size: 80,
                                color: Color.fromARGB(197, 8, 165, 165),
                              ),
                        )
                        : const Icon(
                          Icons.restaurant,
                          size: 80,
                          color: Color.fromARGB(197, 8, 165, 165),
                        ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                restaurant.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
