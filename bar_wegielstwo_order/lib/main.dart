import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/constants.dart';
import 'providers/orders_provider.dart';
import 'providers/menu_provider.dart';
import 'providers/cart_provider.dart';
import 'screens/order_screen.dart';

void main() {
  runApp(const OrderApp());
}

class OrderApp extends StatelessWidget {
  const OrderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => OrdersProvider()),
        ChangeNotifierProvider(create: (_) => MenuProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
      ],
      child: MaterialApp(
        title: 'Bar Węgielstwo - Zamów',
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
        ),
        home: const OrderScreen(),
      ),
    );
  }
}