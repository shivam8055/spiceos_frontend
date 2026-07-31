import 'package:flutter/material.dart';

import '../../models/order_line_item.dart';

class MenuItemTile extends StatelessWidget {
  final OrderLineItem item;
  final VoidCallback onAdd;

  const MenuItemTile({
    super.key,
    required this.item,
    required this.onAdd,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      child: ListTile(
        title: Text(item.name),
        subtitle: Text("₹${item.price.toStringAsFixed(0)}"),
        trailing: FilledButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text("Add"),
        ),
      ),
    );
  }
}