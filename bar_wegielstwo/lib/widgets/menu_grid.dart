import 'package:flutter/material.dart';
import '../models/menu_item_model.dart';

class MenuGrid extends StatelessWidget {
  final List<MenuItemModel> items;
  final MenuItemModel? selectedItem;
  final ValueChanged<MenuItemModel?> onSelect;
  final ValueChanged<MenuItemModel?>? onLongPress;

  const MenuGrid({
    super.key,
    required this.items,
    this.selectedItem,
    required this.onSelect,
    this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40.0),
          child: Text(
            'Brak dostępnych potraw w tej kategorii',
            style: TextStyle(color: Colors.white70, fontSize: 14),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 160,
        childAspectRatio: 1.0,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final isSelected = selectedItem?.name == item.name;
        return GestureDetector(
          onTap: () => onSelect(isSelected ? null : item),
          onLongPress: onLongPress != null ? () => onLongPress!(item) : null,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.white12,
                width: isSelected ? 2 : 1,
              ),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: isSelected
                    ? [const Color(0xFF886649).withAlpha(76), const Color(0xFF886649).withAlpha(25)]
                    : [const Color(0xFF2A1A16).withAlpha(204), const Color(0xFF2A1A16).withAlpha(230)],
              ),
              boxShadow: isSelected
                  ? [BoxShadow(color: const Color(0xFF886649).withAlpha(51), blurRadius: 12)]
                  : [const BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2))],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  item.emoji,
                  style: const TextStyle(fontSize: 32),
                ),
                const SizedBox(height: 6),
                Text(
                  item.name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}