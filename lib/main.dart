import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:project_flutter/blocs/products/products_bloc.dart';
import 'package:project_flutter/screens/login_screen.dart';
import 'package:project_flutter/screens/signup_screen.dart';
import 'package:project_flutter/screens/home_screen.dart';
import 'package:project_flutter/screens/products_screen.dart';
import 'package:project_flutter/services/auth_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<ProductsBloc>(
          create: (context) => ProductsBloc(),
        ),
      ],
      child: MaterialApp(
        title: 'Flutter Auth',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
        home: FutureBuilder<bool>(
          future: AuthService.isLoggedIn(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              );
            }
            
            final isLoggedIn = snapshot.data ?? false;
            if (isLoggedIn) {
              return const HomeScreen();
            } else {
              return const LoginScreen();
            }
          },
        ),
        routes: {
          '/login': (context) => const LoginScreen(),
          '/signup': (context) => SignupScreen(),
          '/home': (context) => const HomeScreen(),
          '/products': (context) => const ProductsScreen(),
        },
      ),
    );
  }
}