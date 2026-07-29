import 'dart:async';
import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';
import '../models/extra_model.dart';
import '../services/api_service.dart';

class MenuProvider extends ChangeNotifier {
  final ApiService _api;
  List<MenuItemModel> _menuItems = [];
  List<ExtraModel> _extras = [];
  List<String> _portions = [];
  Timer? _pollTimer;

  List<MenuItemModel> get menuItems => List.unmodifiable(_menuItems);
  List<ExtraModel> get extras => List.unmodifiable(_extras);
  List<String> get portions => List.unmodifiable(_portions);
  List<MenuItemModel> get availableMenuItems => _menuItems.where((m) => m.available).toList();

  MenuProvider({ApiService? api}) : _api = api ?? ApiService();

  void startPolling({int intervalSeconds = 5}) {
    stopPolling();
    _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) => refreshAll());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> refreshAll() async {
    await Future.wait([fetchMenu(), fetchExtras(), fetchPortions()]);
  }

  Future<void> fetchMenu() async {
    try {
      _menuItems = await _api.getMenuItems();
      notifyListeners();
    } catch (_) {
      debugPrint('MenuProvider: błąd pobierania menu');
    }
  }

  Future<void> fetchExtras() async {
    try {
      _extras = await _api.getExtras();
      notifyListeners();
    } catch (_) {
      debugPrint('MenuProvider: błąd pobierania dodatków');
    }
  }

  Future<void> fetchPortions() async {
    try {
      _portions = await _api.getPortions();
      notifyListeners();
    } catch (_) {
      debugPrint('MenuProvider: błąd pobierania porcji');
    }
  }

  Future<void> addMenuItem(String name, String emoji, String category) async {
    await _api.addMenuItem(name, emoji, category);
    await fetchMenu();
  }

  Future<void> updateMenuItem(String name, Map<String, dynamic> updates) async {
    await _api.updateMenuItem(name, updates);
    await fetchMenu();
  }

  Future<void> deleteMenuItem(String name) async {
    await _api.deleteMenuItem(name);
    await fetchMenu();
  }

  Future<void> addExtra(String name, {String emoji = ''}) async {
    await _api.addExtra(name, emoji: emoji);
    await fetchExtras();
  }

  Future<void> deleteExtra(String name) async {
    await _api.deleteExtra(name);
    await fetchExtras();
  }

  Future<void> updateExtra(String name, {bool? available}) async {
    await _api.updateExtra(name, available: available);
    await fetchExtras();
  }
}