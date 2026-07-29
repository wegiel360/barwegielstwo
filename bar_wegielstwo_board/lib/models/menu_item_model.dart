class MenuItemModel {
  final String name;
  final String emoji;
  final bool available;
  final String category;

  MenuItemModel({
    required this.name,
    required this.emoji,
    this.available = true,
    this.category = 'Inne',
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'emoji': emoji,
        'available': available,
        'category': category,
      };

  factory MenuItemModel.fromJson(Map<String, dynamic> json) => MenuItemModel(
        name: json['name'] as String? ?? 'Pozycja',
        emoji: json['emoji'] as String? ?? '🍽️',
        available: json['available'] as bool? ?? true,
        category: json['category'] as String? ?? 'Inne',
      );
}