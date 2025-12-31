import 'package:flutter/material.dart';
import 'splashscreen.dart';
import 'screens/welcome_screen.dart';
import 'screens/login_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/forgot_password_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/search_screen.dart';
import 'screens/shop_screen.dart';
import 'screens/add_product_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/settings_screen.dart';
//import 'screens/edit_profile_screen.dart';
import 'screens/my_orders_screen.dart';
import 'screens/category_screen.dart';
import 'package:pakcraft/admin/admin_dashboard.dart';

void main() {
  runApp(const PakCraftApp());
}

class PakCraftApp extends StatelessWidget {
  const PakCraftApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PakCraft',
      theme: ThemeData(
        primaryColor: const Color(0xFFFF7F11),
        scaffoldBackgroundColor: Colors.white,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/forgot': (context) => const ForgotPasswordScreen(),
        '/home': (context) => const HomeScreen(),
        '/profile': (context) => const ProfileScreen(),
        '/search': (context) => const SearchScreen(),
        '/shop': (context) => const ShopScreen(),
        '/add': (context) => const AddProductScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/settings': (context) => const SettingsScreen(),
        //'/edit_profile': (context) => const EditProfileScreen(),
        '/my_orders': (context) => const MyOrdersScreen(),
        '/category': (context) =>
            const CategoryScreen(categoryName: '', categoryIcon: ''),
        '/admin': (context) => const AdminDashboard(),
      },
    );
  }
}
