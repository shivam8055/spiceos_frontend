import 'package:flutter/material.dart';

class OrdersStatistics extends StatelessWidget {
  const OrdersStatistics({super.key});

  Widget buildCard(
      String title,
      String value,
      Color color,
      IconData icon,
      ) {
    return Expanded(
      child: Card(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(
            color: Color(0xFFE5E7EB),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                backgroundColor: color.withValues(alpha: .15),
                child: Icon(icon, color: color),
              ),

              const SizedBox(width: 16),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    value,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  Text(title),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        buildCard(
          "Today's Orders",
          "34",
          Colors.blue,
          Icons.receipt_long,
        ),

        const SizedBox(width: 20),

        buildCard(
          "Revenue",
          "₹18,250",
          Colors.green,
          Icons.currency_rupee,
        ),

        const SizedBox(width: 20),

        buildCard(
          "Preparing",
          "8",
          Colors.orange,
          Icons.restaurant,
        ),

        const SizedBox(width: 20),

        buildCard(
          "Delivered",
          "22",
          Colors.purple,
          Icons.check_circle,
        ),
      ],
    );
  }
}