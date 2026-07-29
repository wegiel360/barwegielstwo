import '../models/order_model.dart';

String generateReceipt(OrderModel order) {
  final lines = <String>[
    'Bar Węgielstwo',
    '------------------------------------',
    'Data: ${_formatTimestamp(order.timestamp)}',
    'Numer: ${order.orderNumber}',
  ];

  for (final item in order.items) {
    lines.add('${item.emoji} ${item.name} (${item.portion}) ...... 0,00 zł');
    if (item.extras.isNotEmpty) {
      lines.add('  + gratis: ${item.extras.join(', ')}');
    }
  }

  lines.addAll([
    '------------------------------------',
    '**DO ZAPŁACENIA:** 0,00 zł',
    '**Płatność:** Brak',
    '------------------------------------',
    'Dziękujemy za wizytę!',
  ]);

  return lines.join('\n');
}

String _formatTimestamp(String timestamp) {
  try {
    final dt = DateTime.parse(timestamp);
    return '${dt.day.toString().padLeft(2, '0')}.'
        '${dt.month.toString().padLeft(2, '0')}.'
        '${dt.year} '
        '${dt.hour.toString().padLeft(2, '0')}:'
        '${dt.minute.toString().padLeft(2, '0')}:'
        '${dt.second.toString().padLeft(2, '0')}';
  } catch (_) {
    return timestamp;
  }
}