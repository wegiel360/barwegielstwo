import 'package:flutter/material.dart';

class StatusBadge extends StatelessWidget {
  final String status;
  final double fontSize;

  const StatusBadge({
    super.key,
    required this.status,
    this.fontSize = 0.75,
  });

  Color _getColor() {
    switch (status) {
      case 'Zamówione':
        return Colors.white;
      case 'W realizacji':
        return const Color(0xFFFBBF24);
      case 'Gotowe':
        return const Color(0xFF4ADE80);
      case 'Anulowane':
        return const Color(0xFFF87171);
      case 'Zwrócone':
        return const Color(0xFFA78BFA);
      default:
        return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: _getColor(), width: 1),
      ),
      child: Text(
        status.toUpperCase(),
        style: TextStyle(
          color: _getColor(),
          fontSize: fontSize,
          letterSpacing: 0.05,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}