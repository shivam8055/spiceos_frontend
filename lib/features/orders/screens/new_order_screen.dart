import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_shell.dart';
import '../models/order_line_item.dart';
import '../providers/new_order_provider.dart';
import '../widgets/order_builder/menu_item_tile.dart';
import '../widgets/order_builder/order_summary.dart';

class NewOrderScreen extends ConsumerStatefulWidget {
  const NewOrderScreen({super.key});

  @override
  ConsumerState<NewOrderScreen> createState() => _NewOrderScreenState();
}

class _NewOrderScreenState extends ConsumerState<NewOrderScreen> {
  final customerController = TextEditingController();
  final phoneController = TextEditingController();

  String orderSource = 'Walk-in';

  final menuItems = [
    OrderLineItem(
      id: '1',
      name: 'Chicken Biryani',
      price: 249,
    ),
    OrderLineItem(
      id: '2',
      name: 'Paneer Tikka',
      price: 199,
    ),
    OrderLineItem(
      id: '3',
      name: 'Butter Naan',
      price: 40,
    ),
    OrderLineItem(
      id: '4',
      name: 'Coke',
      price: 50,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Create New Order',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 24),

            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  flex: 2,
                  child: Column(
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            children: [
                              TextField(
                                controller: customerController,
                                decoration: const InputDecoration(
                                  labelText: 'Customer Name',
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                controller: phoneController,
                                decoration: const InputDecoration(
                                  labelText: 'Mobile Number',
                                ),
                              ),
                              const SizedBox(height: 16),
                              DropdownButtonFormField<String>(
                                initialValue: orderSource,
                                decoration: const InputDecoration(
                                  labelText: 'Order Source',
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: 'Walk-in',
                                    child: Text('Walk-in'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'WhatsApp',
                                    child: Text('WhatsApp'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'Website',
                                    child: Text('Website'),
                                  ),
                                  DropdownMenuItem(
                                    value: 'QR Order',
                                    child: Text('QR Order'),
                                  ),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    orderSource = value!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Menu",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 16),

                              ...menuItems.map(
                                    (item) => MenuItemTile(
                                  item: item,
                                  onAdd: () {
                                    ref
                                        .read(newOrderProvider.notifier)
                                        .addItem(item);
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 24),

                const Expanded(
                  child: OrderSummary(),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}