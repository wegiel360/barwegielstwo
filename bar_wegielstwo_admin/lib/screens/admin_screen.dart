import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../models/order_model.dart';
import '../providers/menu_provider.dart';
import '../providers/orders_provider.dart';
import '../services/audio_service.dart';
import '../widgets/order_card.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _currentTab = 0;
  final TextEditingController _newItemName = TextEditingController();
  final TextEditingController _newItemEmoji = TextEditingController();
  final TextEditingController _newItemCategory = TextEditingController();
  final TextEditingController _newExtraName = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().startListening();
      context.read<OrdersProvider>().startListening();
    });
  }

  @override
  void dispose() {
    _newItemName.dispose();
    _newItemEmoji.dispose();
    _newItemCategory.dispose();
    _newExtraName.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final ordersProvider = context.watch<OrdersProvider>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: const Color(0xFF2A1A16),
        title: const Text(
          'Zarzadzanie',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {},
            tooltip: 'Odswiez',
          ),
        ],
      ),
      body: DefaultTabController(
        length: 2,
        child: Column(
          children: [
            TabBar(
              indicatorColor: const Color(0xFF886649),
              labelColor: Colors.white,
              unselectedLabelColor: Colors.white54,
              onTap: (index) => setState(() => _currentTab = index),
              tabs: const [
                Tab(text: 'Zamowienia'),
                Tab(text: 'Menu'),
              ],
            ),
            Expanded(
              child: _currentTab == 0
                  ? _buildOrdersTab(ordersProvider)
                  : _buildMenuTab(menuProvider),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrdersTab(OrdersProvider ordersProvider) {
    final orders = ordersProvider.orders;
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _ringDzwonek,
                  icon: const Icon(Icons.phone, size: 16),
                  label: const Text('Dzwonek', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFFBBF24),
                    side: BorderSide(color: const Color(0xFFFBBF24).withAlpha(76)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _clearAllOrders,
                  icon: const Icon(Icons.delete_sweep, size: 16),
                  label: const Text('Wyczysc', style: TextStyle(fontSize: 12)),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFFF87171),
                    side: BorderSide(color: const Color(0xFFF87171).withAlpha(76)),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        Expanded(
          child: orders.isEmpty
              ? const Center(
                  child: Text('Brak zamowien', style: TextStyle(color: Colors.white54)),
                )
              : RefreshIndicator(
                  onRefresh: () async => ordersProvider.startListening(),
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    itemCount: orders.length,
                    itemBuilder: (context, index) {
                      final order = orders[index];
                      return OrderCard(
                        order: order,
                        onCycleStatus: () => _cycleStatus(ordersProvider, order),
                        onCancel: () => _cancelOrder(ordersProvider, order),
                        onDelete: () => ordersProvider.deleteOrder(order.id),
                      );
                    },
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildMenuTab(MenuProvider menuProvider) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: const Color(0xFF886649),
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white54,
            tabs: const [
              Tab(text: 'Pozycje menu'),
              Tab(text: 'Dodatki gratis'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                _buildMenuItemTab(menuProvider),
                _buildExtrasTab(menuProvider),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItemTab(MenuProvider menuProvider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            children: [
              TextField(
                controller: _newItemName,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Nazwa potrawy',
                  hintStyle: const TextStyle(color: Colors.white54),
                  filled: true,
                  fillColor: const Color(0xFF2A1A16).withAlpha(153),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _newItemEmoji,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Emoji (np. 🍳)',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF2A1A16).withAlpha(153),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: _newItemCategory,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Kategoria',
                        hintStyle: const TextStyle(color: Colors.white54),
                        filled: true,
                        fillColor: const Color(0xFF2A1A16).withAlpha(153),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: _addMenuItem,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF886649),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: const Text('Dodaj pozycje'),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: menuProvider.menuItems.isEmpty
              ? const Center(child: Text('Brak pozycji', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: menuProvider.menuItems.length,
                  itemBuilder: (context, index) {
                    final item = menuProvider.menuItems[index];
                    return ListTile(
                      leading: Text(item.emoji, style: const TextStyle(fontSize: 24)),
                      title: Text(item.name, style: const TextStyle(color: Colors.white)),
                      subtitle: Text(item.category, style: TextStyle(color: Colors.white54, fontSize: 12)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: item.available,
                            onChanged: (val) => menuProvider.updateMenuItem(item.name, {'available': val}),
                            activeThumbColor: const Color(0xFF4ADE80),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 16),
                            onPressed: () => _deleteMenuItem(menuProvider, item.name),
                            splashRadius: 16,
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildExtrasTab(MenuProvider menuProvider) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _newExtraName,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Nazwa dodatku',
                    hintStyle: const TextStyle(color: Colors.white54),
                    filled: true,
                    fillColor: const Color(0xFF2A1A16).withAlpha(153),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _addExtra,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF886649),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text('Dodaj'),
              ),
            ],
          ),
        ),
        Expanded(
          child: menuProvider.extras.isEmpty
              ? const Center(child: Text('Brak dodatkow', style: TextStyle(color: Colors.white54)))
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  itemCount: menuProvider.extras.length,
                  itemBuilder: (context, index) {
                    final extra = menuProvider.extras[index];
                    return ListTile(
                      leading: Text(extra.emoji.isEmpty ? 'plus' : extra.emoji, style: const TextStyle(fontSize: 20)),
                      title: Text(extra.name, style: const TextStyle(color: Colors.white)),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Switch(
                            value: extra.available,
                            onChanged: (val) => menuProvider.updateExtra(extra.name, available: val),
                            activeThumbColor: const Color(0xFF4ADE80),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline, color: Colors.white54, size: 16),
                            onPressed: () => _deleteExtra(menuProvider, extra.name),
                            splashRadius: 16,
                          ),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  void _addMenuItem() {
    final name = _newItemName.text.trim();
    final emoji = _newItemEmoji.text.trim();
    final category = _newItemCategory.text.trim();
    if (name.isEmpty || emoji.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Podaj nazwe i emoji'), backgroundColor: Colors.red),
      );
      return;
    }
    context.read<MenuProvider>().addMenuItem(name, emoji, category.isEmpty ? 'Inne' : category);
    _newItemName.clear();
    _newItemEmoji.clear();
    _newItemCategory.clear();
  }

  void _deleteMenuItem(MenuProvider menuProvider, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A1A16),
        title: Text('Usunac "$name"?', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anuluj', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              menuProvider.deleteMenuItem(name);
            },
            child: const Text('Usun', style: TextStyle(color: Color(0xFFF87171))),
          ),
        ],
      ),
    );
  }

  void _addExtra() {
    final name = _newExtraName.text.trim();
    if (name.isEmpty) return;
    context.read<MenuProvider>().addExtra(name);
    _newExtraName.clear();
  }

  void _deleteExtra(MenuProvider menuProvider, String name) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A1A16),
        title: Text('Usunac dodatek "$name"?', style: const TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anuluj', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              menuProvider.deleteExtra(name);
            },
            child: const Text('Usun', style: TextStyle(color: Color(0xFFF87171))),
          ),
        ],
      ),
    );
  }

  void _ringDzwonek() {
    context.read<OrdersProvider>().triggerDzwonek();
    AudioService().play('assets/sounds/NoweZamowienie.mp3');
  }

  void _clearAllOrders() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A1A16),
        title: const Text('Wyczysc wszystkie?', style: TextStyle(color: Color(0xFFF87171))),
        content: const Text('Czy na pewno chcesz usunac wszystkie zamowienia?', style: TextStyle(color: Colors.white)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Anuluj', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.read<OrdersProvider>().clearAll();
            },
            child: const Text('Usun', style: TextStyle(color: Color(0xFFF87171))),
          ),
        ],
      ),
    );
  }

  void _cycleStatus(OrdersProvider ordersProvider, OrderModel order) {
    final nextStatus = _nextStatusAdmin(order.status);
    ordersProvider.updateStatus(order.id, nextStatus);
  }

  void _cancelOrder(OrdersProvider ordersProvider, OrderModel order) {
    final reasonController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2A1A16),
        title: const Text('Anuluj zamowienie', style: TextStyle(color: Color(0xFFF87171))),
        content: TextField(
          controller: reasonController,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: 'Podaj powod anulowania...',
            hintStyle: TextStyle(color: Colors.white54),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Wroc', style: TextStyle(color: Colors.white)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              ordersProvider.updateStatus(
                order.id,
                'Anulowane',
                reason: reasonController.text.trim().isEmpty ? null : reasonController.text.trim(),
              );
            },
            child: const Text('Anuluj', style: TextStyle(color: Color(0xFFF87171))),
          ),
        ],
      ),
    );
  }

  String _nextStatusAdmin(String current) {
    switch (current) {
      case 'Zamówione':
        return 'W realizacji';
      case 'W realizacji':
        return 'Gotowe';
      case 'Gotowe':
        return 'Zamówione';
      case 'Anulowane':
        return 'Zamówione';
      default:
        return 'Zamówione';
    }
  }
}