import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../config/constants.dart';
import '../models/order_model.dart';
import '../models/menu_item_model.dart';
import '../providers/cart_provider.dart';
import '../providers/menu_provider.dart';
import '../providers/orders_provider.dart';
import '../services/audio_service.dart';
import '../utils/receipt_generator.dart';
import '../widgets/menu_grid.dart';
import '../widgets/cart_widget.dart';
import '../widgets/category_tabs.dart';

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  String _selectedCategory = 'Wszystkie';
  MenuItemModel? _selectedItem;
  String _selectedPortion = '1 porcja';
  final Set<String> _selectedExtras = {};
  bool _showPortions = false;
  bool _showExtras = false;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MenuProvider>().refreshAll();
    });
  }

  @override
  Widget build(BuildContext context) {
    final menuProvider = context.watch<MenuProvider>();
    final cartProvider = context.watch<CartProvider>();
    final menuItems = menuProvider.availableMenuItems;

    final categories = <String>['Wszystkie', ...menuItems.map((m) => m.category).toSet()];
    final filtered = _selectedCategory == 'Wszystkie'
        ? menuItems
        : menuItems.where((m) => m.category == _selectedCategory).toList();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Zamów',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Wybierz potrawy i porcje',
                    style: TextStyle(color: Colors.white60, fontSize: 14),
                  ),
                  const SizedBox(height: 16),
                  CategoryTabs(
                    categories: categories,
                    selectedCategory: _selectedCategory,
                    onSelected: (cat) {
                      setState(() {
                        _selectedCategory = cat;
                        _selectedItem = null;
                        _showPortions = false;
                        _showExtras = false;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (menuProvider.menuItems.isEmpty && !menuProvider.menuItems.any((m) => m.available))
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: Text(
                          'Brak menu',
                          style: TextStyle(color: Colors.white54),
                        ),
                      ),
                    )
                  else
                    MenuGrid(
                      items: filtered,
                      selectedItem: _selectedItem,
                      onSelect: (item) {
                        setState(() {
                          if (_selectedItem?.name == item?.name) {
                            _selectedItem = null;
                            _showPortions = false;
                            _showExtras = false;
                          } else {
                            _selectedItem = item;
                            _showPortions = true;
                            _showExtras = true;
                            _selectedExtras.clear();
                          }
                        });
                      },
                    ),
                  if (_showPortions && _selectedItem != null) ...[
                    const SizedBox(height: 16),
                    const Text(
                      'Wybierz porcję',
                      style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      runSpacing: 6,
                      children: (menuProvider.portions.isEmpty ? ['1 porcja', '2 porcje', 'Pół porcji'] : menuProvider.portions)
                          .map((p) => ChoiceChip(
                                label: Text(p, style: const TextStyle(color: Colors.white, fontSize: 12)),
                                selected: _selectedPortion == p,
                                onSelected: (_) => setState(() => _selectedPortion = p),
                                selectedColor: const Color(0xFF886649).withAlpha(76),
                                labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  side: const BorderSide(color: Colors.white24),
                                ),
                                backgroundColor: const Color(0xFF2A1A16).withAlpha(153),
                              ))
                          .toList(),
                    ),
                    const SizedBox(height: 12),
                    if (_showExtras && menuProvider.extras.isNotEmpty) ...[
                      const Text(
                        'Dodatki gratis',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: menuProvider.extras
                            .where((e) => e.available)
                            .map((e) => ChoiceChip(
                                  label: Text('${e.emoji} ${e.name}', style: const TextStyle(color: Colors.white, fontSize: 12)),
                                  selected: _selectedExtras.contains(e.name),
                                  onSelected: (sel) {
                                    setState(() {
                                      if (sel) {
                                        _selectedExtras.add(e.name);
                                      } else {
                                        _selectedExtras.remove(e.name);
                                      }
                                    });
                                  },
                                  selectedColor: const Color(0xFF886649).withAlpha(76),
                                  labelStyle: const TextStyle(color: Colors.white, fontSize: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                    side: const BorderSide(color: Colors.white24),
                                  ),
                                  backgroundColor: const Color(0xFF2A1A16).withAlpha(153),
                                ))
                            .toList(),
                      ),
                    ],
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              setState(() {
                                _selectedItem = null;
                                _selectedPortion = '1 porcja';
                                _selectedExtras.clear();
                                _showPortions = false;
                                _showExtras = false;
                              });
                            },
                            child: const Text('Pomiń'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: FilledButton(
                            onPressed: () {
                              if (_selectedItem == null) return;
                              final napoje = ['Napoje'];
                              if (napoje.contains(_selectedItem!.category) && _selectedItem!.name != 'Napoje') {
                                _addToCartNapoje();
                              } else {
                                _addToCart();
                              }
                            },
                            child: const Text('Dodaj do koszyka'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
          CartWidget(
            items: cartProvider.items,
            onClear: () {
              if (cartProvider.isEmpty) return;
              showDialog(
                context: context,
                builder: (ctx) => AlertDialog(
                  backgroundColor: const Color(0xFF2A1A16),
                  title: const Text('Wyczyść koszyk?', style: TextStyle(color: Colors.white)),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx),
                      child: const Text('Anuluj', style: TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () {
                        cartProvider.clear();
                        Navigator.pop(ctx);
                      },
                      child: const Text('Wyczyść', style: TextStyle(color: Color(0xFFF87171))),
                    ),
                  ],
                ),
              );
            },
            onPlaceOrder: _isProcessing ? null : () { _placeOrder(); },
            isProcessing: _isProcessing,
          ),
        ],
      ),
    );
  }

  void _addToCart() {
    final item = _selectedItem!;
    final cartProvider = context.read<CartProvider>();
    cartProvider.addItem(OrderItem(
      name: item.name,
      emoji: item.emoji,
      portion: _selectedPortion,
      extras: _selectedExtras.toList(),
    ));
    _resetSelection();
    setState(() {});
  }

  void _addToCartNapoje() {
    final item = _selectedItem!;
    final cartProvider = context.read<CartProvider>();
    cartProvider.addItem(OrderItem(
      name: item.name,
      emoji: item.emoji,
      portion: '1 porcja',
      extras: [],
    ));
    _resetSelection();
    setState(() {
      AudioService().play('assets/sounds/NoweZamowienie.mp3');
    });
  }

  void _resetSelection() {
    _selectedItem = null;
    _selectedPortion = '1 porcja';
    _selectedExtras.clear();
    _showPortions = false;
    _showExtras = false;
  }

  Future<void> _placeOrder() async {
    final cartProvider = context.read<CartProvider>();
    if (cartProvider.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Koszyk jest pusty'), backgroundColor: Colors.red),
        );
      }
      return;
    }

    setState(() => _isProcessing = true);

    try {
      final items = cartProvider.items.map((i) => OrderItem(
        name: i.name,
        emoji: i.emoji,
        portion: i.portion,
        extras: i.extras,
      )).toList();

      final order = await context.read<OrdersProvider>().createOrder(
        items: items,
        customerName: 'Gość',
        notes: '',
      );

      await AudioService().play('assets/sounds/Gotowe.mp3');

      cartProvider.clear();

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF2A1A16),
            title: const Text('Zamówienie złożone!', style: TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: SelectableText(
                generateReceipt(order),
                style: const TextStyle(color: Colors.white, fontSize: 12, fontFamily: 'monospace'),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('OK', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Błąd: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isProcessing = false);
    }
  }
}