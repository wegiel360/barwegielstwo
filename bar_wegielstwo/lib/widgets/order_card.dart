import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../utils/time_formatter.dart';
import 'status_badge.dart';

class OrderCard extends StatelessWidget {
  final OrderModel order;
  final VoidCallback? onTap;
  final VoidCallback? onCycleStatus;
  final VoidCallback? onCancel;
  final VoidCallback? onDelete;

  const OrderCard({
    super.key,
    required this.order,
    this.onTap,
    this.onCycleStatus,
    this.onCancel,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      color: const Color(0xFF2A1A16).withAlpha(128),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '#${order.orderNumber}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          formatOrderTime(order.timestamp),
                          style: TextStyle(
                            color: _timeColor(),
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                  ),
                  StatusBadge(status: order.status),
                ],
              ),
              const SizedBox(height: 8),
              ...order.items.map((item) => Padding(
                    padding: const EdgeInsets.only(bottom: 2),
                    child: Row(
                      children: [
                        Text(item.emoji, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            '${item.name} (${item.portion})',
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  )),
              if (order.reason != null && order.reason!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Text(
                  'Powód: ${order.reason}',
                  style: const TextStyle(color: Color(0xFFF87171), fontSize: 11, fontStyle: FontStyle.italic),
                ),
              ],
              if (onCycleStatus != null || onCancel != null || onDelete != null) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (onCycleStatus != null)
                      TextButton(
                        onPressed: onCycleStatus,
                        child: const Text('Zmień', style: TextStyle(color: Colors.white, fontSize: 12)),
                      ),
                    if (onCancel != null)
                      TextButton(
                        onPressed: onCancel,
                        child: const Text('Anuluj', style: TextStyle(color: Color(0xFFF87171), fontSize: 12)),
                      ),
                    if (onDelete != null)
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 16),
                        onPressed: onDelete,
                        splashRadius: 16,
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _timeColor() {
    final diff = DateTime.now().difference(DateTime.parse(order.timestamp));
    if (diff.inMinutes < 5) return const Color(0xFF4ADE80);
    if (diff.inMinutes < 15) return const Color(0xFFFBBF24);
    if (diff.inMinutes < 30) return const Color(0xFFFFFFFF);
    return const Color(0xFFFFFFFF).withAlpha(128);
  }
}