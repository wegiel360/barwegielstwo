import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF1A1210);
  static const Color surface = Color(0xFF2A1A16);
  static const Color surfaceLight = Color(0xFF3A2A24);
  static const Color accent = Color(0xFF886649);
  static const Color accentLight = Color(0xFFC49A6C);
  static const Color primary = Color(0xFFE8D5B8);
  static const Color text = Color(0xFFFFFFFF);
  static const Color textMuted = Color(0xFFB8A090);
  static const Color success = Color(0xFF4ADE80);
  static const Color warning = Color(0xFFFBBF24);
  static const Color error = Color(0xFFF87171);
  static const Color info = Color(0xFF60A5FA);
  static const Color purple = Color(0xFFA78BFA);
  static const Color orange = Color(0xFFFB923C);
  static const Color pink = Color(0xFFF472B6);
}

class AppDimensions {
  static const double borderRadius = 12.0;
  static const double borderRadiusSm = 8.0;
  static const double borderRadiusLg = 16.0;
  static const double paddingScreen = 16.0;
  static const double paddingCard = 16.0;
  static const double spacingSm = 8.0;
  static const double spacingMd = 16.0;
  static const double spacingLg = 24.0;
  static const double spacingXl = 32.0;
  static const double iconSize = 24.0;
  static const double fontSizeXs = 0.75;
  static const double fontSizeSm = 0.85;
  static const double fontSizeMd = 0.9;
  static const double fontSizeLg = 1.0;
  static const double fontSizeXl = 1.1;
  static const double fontSizeXxl = 1.3;
  static const double fontSizeDisplay = 1.75;
  static const double bottomSheetHeight = 200.0;
  static const double animationDurationMs = 200;
  static const double animationDurationSlowMs = 350;
}

class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:6969';
  static const int connectionTimeoutMs = 5000;
  static const int receiveTimeoutMs = 10000;
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