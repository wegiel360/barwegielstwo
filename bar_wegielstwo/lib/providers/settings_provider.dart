import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';

class SettingsProvider extends ChangeNotifier {
  final ApiService _api;
  String _customMessage = 'Witaj w Barze Węgielstwo!';
  String _danieDnia = '';
  Timer? _pollTimer;

  String get customMessage => _customMessage;
  String get danieDnia => _danieDnia;

  SettingsProvider({ApiService? api}) : _api = api ?? ApiService();

  void startPolling({int intervalSeconds = 10}) {
    stopPolling();
    _pollTimer = Timer.periodic(Duration(seconds: intervalSeconds), (_) => refresh());
  }

  void stopPolling() {
    _pollTimer?.cancel();
    _pollTimer = null;
  }

  Future<void> refresh() async {
    await Future.wait([fetchMessage(), fetchDanieDnia()]);
  }

  Future<void> fetchMessage() async {
    try {
      _customMessage = await _api.getCustomMessage();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> fetchDanieDnia() async {
    try {
      _danieDnia = await _api.getDanieDnia();
      notifyListeners();
    } catch (_) {}
  }

  Future<void> setCustomMessage(String message) async {
    await _api.setCustomMessage(message);
    await fetchMessage();
  }

  Future<void> setDanieDnia(String danie) async {
    await _api.setDanieDnia(danie);
    await fetchDanieDnia();
  }
}