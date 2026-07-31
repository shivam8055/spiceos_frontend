import 'package:flutter/material.dart';

import '../models/order.dart';

class PaymentStatusChip extends StatelessWidget {
  final PaymentStatus status;

  const PaymentStatusChip({
    super.key,
    required this.status,
  });

  @override
  Widget build(BuildContext context) {
    switch (status) {
      case PaymentStatus.paid:
        return const Chip(
          label: Text("Paid"),
          backgroundColor: Colors.greenAccent,
        );

      case PaymentStatus.pending:
        return const Chip(
          label: Text("Pending"),
          backgroundColor: Colors.orangeAccent,
        );

      case PaymentStatus.refunded:
        return const Chip(
          label: Text("Refunded"),
          backgroundColor: Colors.redAccent,
        );
    }
  }
}