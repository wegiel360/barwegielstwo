import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../models/order_model.dart';
import '../providers/orders_provider.dart';
import '../services/audio_service.dart';
import '../widgets/order_card.dart';
import '../widgets/bouncing_logo.dart';

class BoardScreen extends StatefulWidget {
  const BoardScreen({super.key});

  @override
  State<BoardScreen> createState() => _BoardScreenState();
}

class _BoardScreenState extends State<BoardScreen> {
  final Map<String, String> _lastStatuses = {};
  Timer? _cleanupTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrdersProvider>().startPolling(intervalSeconds: 3);
    });
    _cleanupTimer = Timer.periodic(const Duration(seconds: 30), (_) => _checkCleanup());
  }

  @override
  void dispose() {
    _cleanupTimer?.cancel();
    context.read<OrdersProvider>().stopPolling();
    super.dispose();
  }

  void _checkCleanup() {
    final orders = context.read<OrdersProvider>().orders;
    final now = DateTime.now();
    for (final order in orders) {
      if (order.status == StatusLabels.gotowe && order.timestamp.isNotEmpty) {
        try {
          final ts = DateTime.parse(order.timestamp);
          if (now.difference(ts).inMinutes > 30) {
            context.read<OrdersProvider>().deleteOrder(order.id);
          }
        } catch (_) {}
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final ordersProvider = context.watch<OrdersProvider>();
    final orders = ordersProvider.orders;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Bouncing logos
          Positioned(
            top: 100,
            left: 50,
            child: BouncingLogo(
              imageAsset: 'assets/images/BarWegielstwo.png',
              width: 180,
              height: 99,
              speed: 2.0,
              enabled: true,
            ),
          ),
          if (orders.isNotEmpty)
            Positioned(
              top: 200,
              right: 30,
              child: BouncingLogo(
                imageAsset: 'assets/images/BarWegielstwo.png',
                width: 50,
                height: 28,
                speed: 1.4,
                enabled: true,
              ),
            ),
          // Content
          SafeArea(
            child: Column(
              children: [
                if (orders.isEmpty)
                  const Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Zamów coś!',
                            style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w700),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Brak aktywnych zamówień',
                            style: TextStyle(color: Colors.white54, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  )
                else
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: orders.length,
                      itemBuilder: (context, index) {
                        final order = orders[index];
                        final prevStatus = _lastStatuses[order.id];
                        final statusChanged = prevStatus != null && prevStatus != order.status;
                        if (statusChanged) {
                          _lastStatuses[order.id] = order.status;
                          Future.delayed(Duration.zero, () => _playStatusSound(order.status));
                        } else if (prevStatus == null) {
                          _lastStatuses[order.id] = order.status;
                        }
                        return OrderCard(
                          order: order,
                          onCycleStatus: () => _cycleStatus(context, order),
                          onCancel: () => _cancelOrder(context, order),
                          onDelete: () => _deleteOrder(context, order),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _playStatusSound(String status) {
    String sound;
    switch (status) {
      case StatusLabels.zamowione:
        sound = 'assets/sounds/NoweZamowienie.mp3';
        break;
      case StatusLabels.wRealizacji:
        sound = 'assets/sounds/Wrealizacji.mp3';
        break;
      case StatusLabels.gotowe:
        sound = 'assets/sounds/Gotowe.mp3';
        break;
      case StatusLabels.anulowane:
        sound = 'assets/sounds/anulowano.mp3';
        break;
      default:
        return;
    }
    AudioService().play(sound);
  }

  void _cycleStatus(BuildContext context, OrderModel order) {
    final nextStatus = _nextStatus(order.status);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A1A16),
        title: Text('Zmień status na "$nextStatus"?', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anuluj', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OrdersProvider>().updateStatus(order.id, nextStatus);
            },
            child: Text(nextStatus, style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _cancelOrder(BuildContext context, OrderModel order) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A1A16),
        title: const Text('Anuluj zamówienie', style: TextStyle(color: Color(0xFFF87171))),
        content: TextField(
          controller: reasonController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Podaj powód anulowania...',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Wróć', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OrdersProvider>().updateStatus(
                order.id,
                StatusLabels.anulowane,
                reason: reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
              );
            },
            child: const Text('Anuluj', style: TextStyle(color: Color(0xFFF87171))),
          ),
        ],
      ),
    );
  }

  void _deleteOrder(BuildContext context, OrderModel order) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A1A16),
        title: const Text('Usunąć zamówienie?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Wróć', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OrdersProvider>().deleteOrder(order.id);
            },
            child: const Text('Usuń', style: TextStyle(color: Color(0xFFF87171))),
          ),
        ],
      ),
    );
  }

  String _nextStatus(String current) {
    switch (current) {
      case StatusLabels.zamowione:
        return StatusLabels.wRealizacji;
      case StatusLabels.wRealizacji:
        return StatusLabels.gotowe;
      case StatusLabels.gotowe:
        return StatusLabels.zamowione;
      case StatusLabels.anulowane:
        return StatusLabels.zamowione;
      default:
        return StatusLabels.zamowione;
    }
  }
}