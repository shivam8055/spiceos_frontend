import 'package:flutter/material.dart';

class OrdersHeader extends StatelessWidget {
  const OrdersHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "Orders",
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 6),
            Text(
              "Manage all restaurant orders",
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
          ],
        ),

        const Spacer(),

        FilledButton.icon(
          onPressed: () {
            Navigator.pushNamed(context, '/orders/new');
          },
          icon: const Icon(Icons.add),
          label: const Text("New Order"),
        ),
      ],
    );
  }
}