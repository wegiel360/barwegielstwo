import 'dart:async';
import 'package:flutter/material.dart';
import '../config/constants.dart';
import '../models/order_model.dart';
import '../services/api_service.dart';

class OrdersProvider extends ChangeNotifier {
  final ApiService _api;
  List<OrderModel> _orders = [];
  Timer? _pollTimer;

  List<OrderModel> get orders => List.unmodifiable(_orders);
  int get activeCount => _orders.where((o) => o.status != StatusLabels.anulowane && o.status != StatusLabels.gotowe).length;

  OrdersProvider({ApiService? api}) : _api = api ?? ApiService();

  void startPolling({int intervalSeconds = 3}) {
    stopPolling();
    _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) => fetchOrders());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> fetchOrders() async {
    try {
      final fetched = await _api.getOrders();
      _orders = fetched.where((o) => o.status != StatusLabels.gotowe).toList();
      notifyListeners();
    } catch (_) {
      debugPrint('OrdersProvider: błąd pobierania zamówień');
    }
  }

  Future<OrderModel> createOrder({
    required List<OrderItem> items,
    String customerName = 'Gość',
    String notes = '',
  }) async {
    final order = await _api.createOrder(
      items: items,
      customerName: customerName,
      notes: notes,
    );
    _orders.insert(0, order);
    notifyListeners();
    return order;
  }

  Future<void> updateStatus(String orderId, String status, {String? reason}) async {
    await _api.updateOrderStatus(orderId, status, reason: reason);
    final idx = _orders.indexWhere((o) => o.id == orderId);
    if (idx >= 0) {
      _orders[idx] = OrderModel(
        id: _orders[idx].id,
        orderNumber: _orders[idx].orderNumber,
        items: _orders[idx].items,
        status: status,
        customerName: _orders[idx].customerName,
        timestamp: _orders[idx].timestamp,
        notes: _orders[idx].notes,
        reason: reason ?? _orders[idx].reason,
      );
      notifyListeners();
    }
  }

  Future<void> deleteOrder(String orderId) async {
    await _api.deleteOrder(orderId);
    _orders.removeWhere((o) => o.id == orderId);
    notifyListeners();
  }

  Future<void> clearAll() async {
    await _api.clearAllOrders();
    _orders = [];
    notifyListeners();
  }

  Future<void> triggerDzwonek() async {
    await _api.triggerDzwonek();
  }

  OrderModel? findById(String orderId) {
    return _orders.firstWhere((o) => o.id == orderId, orElse: () => OrderModel(
      id: '', orderNumber: '', items: [], status: '', customerName: '', timestamp: '', notes: '',
    ));
  }
}