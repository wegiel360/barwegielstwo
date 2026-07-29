import 'extra_model.dart';
import 'menu_item_model.dart';

class AppSettings {
  final String customMessage;
  final String danieDnia;
  final List<String> portions;
  final List<ExtraModel> extras;
  final List<MenuItemModel> menuItems;
  final int receiptCounter;

  AppSettings({
    this.customMessage = 'Witaj w Barze Węgielstwo!',
    this.danieDnia = '',
    this.portions = const ['1 porcja', '2 porcje', 'Pół porcji'],
    this.extras = const [],
    this.menuItems = const [],
    this.receiptCounter = 0,
  });

  factory AppSettings.fromDatabaseJson(Map<String, dynamic> json) {
    var rawExtras = json['extras'] as List<dynamic>? ?? [];
    var rawMenu = json['menu_items'] as List<dynamic>? ?? [];

    return AppSettings(
      customMessage: json['custom_message'] as String? ??
          'Witaj w Barze Węgielstwo!',
      danieDnia: json['danie_dnia'] as String? ?? '',
      portions: (json['portions'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          ['1 porcja', '2 porcje', 'Pół porcji'],
      extras: rawExtras.map((e) => ExtraModel.fromJson(e)).toList(),
      menuItems: rawMenu
          .map((m) => MenuItemModel.fromJson(m as Map<String, dynamic>))
          .toList(),
      receiptCounter: json['receipt_counter'] as int? ?? 0,
    );
  }
}