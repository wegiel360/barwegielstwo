class ExtraModel {
  final String name;
  final String emoji;
  final bool available;

  ExtraModel({
    required this.name,
    this.emoji = '',
    this.available = true,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'emoji': emoji,
        'available': available,
      };

  factory ExtraModel.fromJson(dynamic json) {
    if (json is String) {
      return ExtraModel(name: json);
    }
    if (json is Map<String, dynamic>) {
      return ExtraModel(
        name: json['name'] as String? ?? '',
        emoji: json['emoji'] as String? ?? '',
        available: json['available'] as bool? ?? true,
      );
    }
    return ExtraModel(name: json.toString());
  }
}