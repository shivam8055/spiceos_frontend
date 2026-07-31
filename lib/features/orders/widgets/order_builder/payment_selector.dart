import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/pricing_provider.dart';

class PaymentSelector extends ConsumerWidget {
  const PaymentSelector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final payment =
    ref.watch(paymentMethodProvider);

    return DropdownButtonFormField<String>(
      initialValue: payment,
      decoration: const InputDecoration(
        labelText: "Payment Method",
      ),
      items: const [
        DropdownMenuItem(
          value: "Cash",
          child: Text("Cash"),
        ),
        DropdownMenuItem(
          value: "UPI",
          child: Text("UPI"),
        ),
        DropdownMenuItem(
          value: "Card",
          child: Text("Card"),
        ),
      ],
      onChanged: (value) {
        ref.read(paymentMethodProvider.notifier).state =
        value!;
      },
    );
  }
}