import 'package:flutter/material.dart';

class ExpenseCardWidget extends StatelessWidget {
  final String merchantName;
  final String categoryName;
  final String formattedDateTime;
  final double totalAmount;
  final String note;

  const ExpenseCardWidget({
    super.key,
    required this.merchantName,
    required this.categoryName,
    required this.formattedDateTime,
    required this.totalAmount,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ExpansionTile(
        title: Row(
          children: [
            const Icon(Icons.shopping_cart, size: 20, color: Colors.blueGrey),
            const SizedBox(width: 6),
            Text(merchantName, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 6),
            const Icon(Icons.sell, size: 20, color: Colors.orange),
            const SizedBox(width: 6),
            Text(categoryName, style: const TextStyle(fontWeight: FontWeight.w500)),
          ],
        ),
        subtitle: Text(formattedDateTime, style: const TextStyle(fontSize: 12)),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(width: 4),
            Text('€${totalAmount.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Icon(
              Icons.expand_more,
              color: Colors.grey.shade600,
            ),
          ],
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(note.isNotEmpty ? note : 'Nessuna nota'),
          ),
        ],
      ),
    );
  }
}