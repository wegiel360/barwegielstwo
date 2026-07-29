import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';
import '../models/order_model.dart';
import '../models/menu_item_model.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _client = client ?? http.Client();

  String _url(String path) => '$baseUrl$path';

  Future<List<OrderModel>> getOrders() async {
    final resp = await _client.get(Uri.parse(_url(ApiConfig.ordersEndpoint)));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((e) => OrderModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Błąd pobierania zamówień: ${resp.statusCode}');
  }

  Future<void> updateOrderStatus(String orderId, String status, {String? reason}) async {
    final body = <String, dynamic>{'status': status};
    if (reason != null) body['reason'] = reason;
    final resp = await _client.put(
      Uri.parse(_url('${ApiConfig.ordersEndpoint}/$orderId')),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode(body),
    );
    if (resp.statusCode != 200) throw Exception('Błąd aktualizacji zamówienia');
  }

  Future<void> deleteOrder(String orderId) async {
    final resp = await _client.delete(Uri.parse(_url('${ApiConfig.ordersEndpoint}/$orderId')));
    if (resp.statusCode != 200) throw Exception('Błąd usuwania zamówienia');
  }

  Future<void> clearAllOrders() async {
    final resp = await _client.delete(Uri.parse(_url('${ApiConfig.ordersEndpoint}/clear')));
    if (resp.statusCode != 200) throw Exception('Błąd czyszczenia zamówień');
  }

  Future<List<MenuItemModel>> getMenuItems() async {
    final resp = await _client.get(Uri.parse(_url(ApiConfig.menuEndpoint)));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as List<dynamic>;
      return data.map((e) => MenuItemModel.fromJson(e as Map<String, dynamic>)).toList();
    }
    throw Exception('Błąd pobierania menu');
  }

  Future<void> triggerDzwonek() async {
    final resp = await _client.post(
      Uri.parse(_url(ApiConfig.dzwonekEndpoint)),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({}),
    );
    if (resp.statusCode != 200) throw Exception('Błąd wywołania dzwonka');
  }

  Future<String> getCustomMessage() async {
    final resp = await _client.get(Uri.parse(_url(ApiConfig.messageEndpoint)));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['message'] as String? ?? '';
    }
    return '';
  }

  Future<void> setCustomMessage(String message) async {
    final resp = await _client.post(
      Uri.parse(_url(ApiConfig.messageEndpoint)),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'message': message}),
    );
    if (resp.statusCode != 200) throw Exception('Błąd zapisu wiadomości');
  }

  Future<String> getDanieDnia() async {
    final resp = await _client.get(Uri.parse(_url(ApiConfig.danieDniaEndpoint)));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['danie'] as String? ?? '';
    }
    return '';
  }

  Future<void> setDanieDnia(String danie) async {
    final resp = await _client.post(
      Uri.parse(_url(ApiConfig.danieDniaEndpoint)),
      headers: {'Content-Type': 'application/json; charset=utf-8'},
      body: jsonEncode({'danie': danie}),
    );
    if (resp.statusCode != 200) throw Exception('Błąd zapisu dania dnia');
  }

  Future<void> requestCleanup() async {
    final resp = await _client.post(Uri.parse(_url(ApiConfig.cleanupEndpoint)));
    if (resp.statusCode != 200) throw Exception('Błąd czyszczenia');
  }

  Stream<List<OrderModel>> ordersStream() {
    return Stream.periodic(const Duration(seconds: 2), (int _) => 0)
        .asyncMap((_) async {
      try {
        return await getOrders();
      } catch (_) {
        return <OrderModel>[];
      }
    });
  }

  Stream<List<MenuItemModel>> menuItemsStream() {
    return Stream.periodic(const Duration(seconds: 5), (int _) => 0)
        .asyncMap((_) async {
      try {
        return await getMenuItems();
      } catch (_) {
        return <MenuItemModel>[];
      }
    });
  }

  Stream<String> customMessageStream() {
    return Stream.periodic(const Duration(seconds: 5), (int _) => 0)
        .asyncMap((_) async {
      try {
        return await getCustomMessage();
      } catch (_) {
        return '';
      }
    }).distinct();
  }

  Stream<String> danieDniaStream() {
    return Stream.periodic(const Duration(seconds: 10), (int _) => 0)
        .asyncMap((_) async {
      try {
        return await getDanieDnia();
      } catch (_) {
        return '';
      }
    }).distinct();
  }
}
