import 'package:flutter/material.dart';
import '../models/order.dart';

class OrderStatusChip extends StatelessWidget {
  final OrderStatus status;

  const OrderStatusChip({
    super.key,
    required this.status,
  });

  Color get color {
    switch (status) {
      case OrderStatus.created:
        return Colors.grey;

      case OrderStatus.preparing:
        return Colors.orange;

      case OrderStatus.ready:
        return Colors.blue;

      case OrderStatus.outForDelivery:
        return Colors.purple;

      case OrderStatus.delivered:
        return Colors.green;

      case OrderStatus.cancelled:
        return Colors.red;
    }
  }

  String get label {
    switch (status) {
      case OrderStatus.created:
        return 'New';

      case OrderStatus.preparing:
        return 'Preparing';

      case OrderStatus.ready:
        return 'Ready';

      case OrderStatus.outForDelivery:
        return 'Out for Delivery';

      case OrderStatus.delivered:
        return 'Delivered';

      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(color: Colors.white),
      ),
      backgroundColor: color,
    );
  }
}