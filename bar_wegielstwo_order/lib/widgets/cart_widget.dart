import 'package:flutter/material.dart';
import '../models/order_model.dart';

class CartWidget extends StatelessWidget {
  final List<OrderItem> items;
  final VoidCallback? onClear;
  final VoidCallback? onPlaceOrder;
  final bool isProcessing;

  const CartWidget({
    super.key,
    required this.items,
    this.onClear,
    this.onPlaceOrder,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2A1A16), Color(0xFF2A1A16)],
        ),
        border: Border.all(color: const Color(0xFF886649).withAlpha(25)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(102),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Koszyk',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: const Color(0xFF886649).withAlpha(38),
                  borderRadius: BorderRadius.circular(50),
                ),
                child: Text(
                  '${items.length}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (items.isEmpty)
            const Text(
              'Koszyk jest pusty',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            )
          else
            SizedBox(
              height: 160,
              child: ListView.separated(
                shrinkWrap: true,
                itemCount: items.length,
                separatorBuilder: (context, index) => Divider(color: const Color(0xFF886649).withAlpha(25)),
                itemBuilder: (context, index) {
                  final item = items[index];
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${item.emoji} ${item.name}',
                              style: const TextStyle(color: Colors.white, fontSize: 13),
                            ),
                            Text(
                              'Porcja: ${item.portion}',
                              style: const TextStyle(color: Colors.white54, fontSize: 11),
                            ),
                            if (item.extras.isNotEmpty)
                              Text(
                                ' gratis: ${item.extras.join(', ')}',
                                style: const TextStyle(color: Color(0xFF886649), fontSize: 11),
                              ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white54, size: 18),
                        onPressed: onClear,
                        padding: EdgeInsets.zero,
                        splashRadius: 20,
                      ),
                    ],
                  );
                },
              ),
            ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: isProcessing ? null : onClear,
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: const Color(0xFF886649).withAlpha(76)),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: const Text('Wyczysc'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: FilledButton(
                  onPressed: isProcessing ? null : onPlaceOrder,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF886649),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(vertical: 10),
                  ),
                  child: isProcessing
                      ? const SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Text('Zamow', style: TextStyle(fontWeight: FontWeight.w600)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}