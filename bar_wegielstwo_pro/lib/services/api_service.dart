import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/constants.dart';

class ApiService {
  final String baseUrl;
  final http.Client _client;

  ApiService({String? baseUrl, http.Client? client})
      : baseUrl = baseUrl ?? ApiConfig.baseUrl,
        _client = client ?? http.Client();

  String _url(String path) => '$baseUrl$path';

  Future<String> getCustomMessage() async {
    final resp = await _client.get(Uri.parse(_url(ApiConfig.messageEndpoint)));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['message'] as String? ?? '';
    }
    return '';
  }

  Future<String> getDanieDnia() async {
    final resp = await _client.get(Uri.parse(_url(ApiConfig.danieDniaEndpoint)));
    if (resp.statusCode == 200) {
      final data = jsonDecode(resp.body) as Map<String, dynamic>;
      return data['danie'] as String? ?? '';
    }
    return '';
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
