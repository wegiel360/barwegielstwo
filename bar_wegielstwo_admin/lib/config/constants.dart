import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF1A1210);
  static const Color surface = Color(0xFF2A1A16);
  static const Color accent = Color(0xFF886649);
  static const Color primary = Color(0xFFE8D5B8);
  static const Color text = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB8A090);
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color purple = Color(0xFFA78BFA);
}

class ApiConfig {
  static const String baseUrl = 'https://wegiel.pythonanywhere.com';
  static const String ordersEndpoint = '/api/orders';
  static const String menuEndpoint = '/api/menu';
  static const String portionsEndpoint = '/api/portions';
  static const String extrasEndpoint = '/api/extras';
  static const String dzwonekEndpoint = '/api/dzwonek';
  static const String messageEndpoint = '/api/message';
  static const String danieDniaEndpoint = '/api/danie-dnia';
  static const String cleanupEndpoint = '/api/cleanup';
  static const String databaseEndpoint = '/bazadanych.json';
}

class StatusLabels {
  static const String zamowione = 'Zamówione';
  static const String wRealizacji = 'W realizacji';
  static const String gotowe = 'Gotowe';
  static const String anulowane = 'Anulowane';
  static const String zwrocone = 'Zwrócone';
}