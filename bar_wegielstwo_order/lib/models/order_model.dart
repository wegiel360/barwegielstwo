class OrderItem {
  final String name;
  final String emoji;
  final String portion;
  final List<String> extras;

  OrderItem({
    required this.name,
    required this.emoji,
    required this.portion,
    required this.extras,
  });

  Map<String, dynamic> toJson() => {
        'name': name,
        'emoji': emoji,
        'portion': portion,
        'extras': extras,
      };

  factory OrderItem.fromJson(Map<String, dynamic> json) => OrderItem(
        name: json['name'] as String? ?? 'Pozycja',
        emoji: json['emoji'] as String? ?? '🍽️',
        portion: json['portion'] as String? ?? '1 porcja',
        extras: (json['extras'] as List<dynamic>?)
                ?.map((e) => e.toString())
                .toList() ??
            [],
      );
}

class OrderModel {
  final String id;
  final String orderNumber;
  final List<OrderItem> items;
  final String status;
  final String customerName;
  final String timestamp;
  final String notes;
  final String? reason;

  OrderModel({
    required this.id,
    required this.orderNumber,
    required this.items,
    required this.status,
    required this.customerName,
    required this.timestamp,
    required this.notes,
    this.reason,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'order_number': orderNumber,
        'items': items.map((i) => i.toJson()).toList(),
        'status': status,
        'customer_name': customerName,
        'timestamp': timestamp,
        'notes': notes,
        if (reason != null) 'reason': reason,
      };

  factory OrderModel.fromJson(Map<String, dynamic> json) => OrderModel(
        id: json['id'] as String? ?? '',
        orderNumber: json['order_number'] as String? ?? '',
        items: ((json['items'] as List<dynamic>?) ?? [])
            .map((e) => OrderItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        status: json['status'] as String? ?? 'Zamówione',
        customerName: json['customer_name'] as String? ?? 'Gość',
        timestamp: json['timestamp'] as String? ?? '',
        notes: json['notes'] as String? ?? '',
        reason: json['reason'] as String?,
      );
}