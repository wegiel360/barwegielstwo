import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/order_model.dart';

class CartProvider extends ChangeNotifier {
  List<OrderItem> _items = [];

  List<OrderItem> get items => List.unmodifiable(_items);
  int get count => _items.length;
  bool get isEmpty => _items.isEmpty;

  CartProvider() {
    _loadCart();
  }

  Future<void> _loadCart() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString('kiosk_cart');
    if (saved != null) {
      try {
        final decoded = jsonDecode(saved) as List<dynamic>;
        _items = decoded.map((e) => OrderItem.fromJson(e as Map<String, dynamic>)).toList();
        notifyListeners();
      } catch (_) {
        _items = [];
      }
    }
  }

  Future<void> _saveCart() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      'kiosk_cart',
      jsonEncode(_items.map((i) => i.toJson()).toList()),
    );
  }

  void addItem(OrderItem item) {
    _items.add(item);
    notifyListeners();
    _saveCart();
  }

  void removeItem(String itemId) {
    _items.removeWhere((item) => itemId == item.name);
    notifyListeners();
    _saveCart();
  }

  void clear() {
    _items = [];
    notifyListeners();
    _saveCart();
  }
}