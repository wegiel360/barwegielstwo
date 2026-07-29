import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF1A1210);
  static const Color surface = Color(0xFF2A1A16);
  static const Color accent = Color(0xFF886649);
  static const Color primary = Color(0xFFE8D5B8);
  static const Color text = Color(0xFFFFFFFF);
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