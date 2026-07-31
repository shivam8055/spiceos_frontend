import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/pricing_provider.dart';

class DiscountCard extends ConsumerWidget {
  const DiscountCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return TextFormField(
      decoration: const InputDecoration(
        labelText: "Discount",
        prefixText: "₹ ",
      ),
      keyboardType: TextInputType.number,
      onChanged: (value) {
        ref.read(discountProvider.notifier).state =
            double.tryParse(value) ?? 0;
      },
    );
  }
}