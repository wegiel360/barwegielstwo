import 'package:flutter/material.dart';

class CategoryTabs extends StatelessWidget {
  final List<String> categories;
  final String selectedCategory;
  final ValueChanged<String> onSelected;

  const CategoryTabs({
    super.key,
    required this.categories,
    required this.selectedCategory,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Row(
        children: categories.map((cat) {
          final isSelected = cat == selectedCategory;
          final label = cat == 'Wszystkie' ? 'Wszystkie' : (cat == 'Inne' ? 'Inne' : cat);
          return Padding(
            padding: const EdgeInsets.only(right: 6),
            child: ChoiceChip(
              label: Text(label, style: TextStyle(color: Colors.white, fontSize: 12)),
              selected: isSelected,
              onSelected: (_) => onSelected(cat),
              selectedColor: const Color(0xFF886649).withAlpha(76),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.white60,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
                side: BorderSide(color: isSelected ? Colors.white30 : Colors.white12),
              ),
              backgroundColor: const Color(0xFF2A1A16).withAlpha(153),
            ),
          );
        }).toList(),
      ),
    );
  }
}