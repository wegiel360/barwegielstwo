import 'dart:async';
import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import '../models/extra_model.dart';
import '../services/api_service.dart';

class MenuProvider extends ChangeNotifier {
  final ApiService _api;
  List<MenuItemModel> _menuItems = [];
  List<ExtraModel> _extras = [];
  StreamSubscription? _menuSub;
  StreamSubscription? _extrasSub;
  bool _isLoaded = false;

  List<MenuItemModel> get menuItems => List.unmodifiable(_menuItems);
  List<ExtraModel> get extras => List.unmodifiable(_extras);
  List<MenuItemModel> get availableMenuItems => _menuItems.where((m) => m.available).toList();
  bool get isLoading => !_isLoaded;

  MenuProvider({ApiService? api})
      : _api = api ?? ApiService();

  void startListening() {
    _menuSub?.cancel();
    _menuSub = _api.menuItemsStream().listen((items) {
      _menuItems = items;
      _isLoaded = true;
      notifyListeners();
    });
    _extrasSub?.cancel();
    _extrasSub = _api.extrasStream().listen((extrasList) {
      _extras = extrasList;
      notifyListeners();
    });
  }

  Future<void> addMenuItem(String name, String emoji, String category) async {
    await _api.addMenuItem(name, emoji, category);
  }

  Future<void> updateMenuItem(String name, Map<String, dynamic> updates) async {
    await _api.updateMenuItem(name, updates);
  }

  Future<void> deleteMenuItem(String name) async {
    await _api.deleteMenuItem(name);
  }

  Future<void> addExtra(String name, {String emoji = ''}) async {
    await _api.addExtra(name, emoji: emoji);
  }

  Future<void> deleteExtra(String name) async {
    await _api.deleteExtra(name);
  }

  Future<void> updateExtra(String name, {bool? available}) async {
    await _api.updateExtra(name, available: available);
  }
}