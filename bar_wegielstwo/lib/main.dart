import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/constants.dart';
import 'providers/orders_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/order_screen.dart';
import 'screens/board_screen.dart';
import 'screens/admin_screen.dart';

void main() {
  runApp(const BarWegielstwoApp());
}

class BarWegielstwoApp extends StatelessWidget {
  const BarWegielstwoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
      child: MaterialApp(
        title: 'Bar Węgielstwo',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          scaffoldBackgroundColor: AppColors.background,
          colorScheme: ColorScheme.dark(
            primary: const Color(0xFF886649),
            secondary: const Color(0xFFC49A6C),
            surface: const Color(0xFF2A1A16),
            onSurface: Colors.white,
          ),
          textTheme: const TextTheme(
            displayLarge: TextStyle(color: Colors.white),
            displayMedium: TextStyle(color: Colors.white),
            bodyLarge: TextStyle(color: Colors.white),
            bodyMedium: TextStyle(color: Colors.white),
          ),
        ),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: const Text(
            'Bar Węgielstwo',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
          ),
          backgroundColor: const Color(0xFF2A1A16),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            indicatorColor: Color(0xFF886649),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: [
              Tab(text: '🛒 Zamów'),
              Tab(text: '📋 Tablica'),
              Tab(text: '⚙️ Zarządzanie'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            OrderScreen(),
            BoardScreen(),
            AdminScreen(),
          ],
        ),
      ),
    );
  }
}