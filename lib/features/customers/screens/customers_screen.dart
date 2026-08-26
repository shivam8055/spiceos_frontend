import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/app_shell.dart';

class CustomersScreen extends ConsumerStatefulWidget {
  const CustomersScreen({super.key});

  @override
  ConsumerState<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends ConsumerState<CustomersScreen> {
  late Future<List<Map<String, dynamic>>> _future;
  String _query = '';

  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<List<Map<String, dynamic>>> _load() async {
    final response = await ref.read(apiClientProvider).get('/customers');
    return List<Map<String, dynamic>>.from(
      (response.data as List).map((item) => Map<String, dynamic>.from(item as Map)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: FutureBuilder<List<Map<String, dynamic>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                const Icon(Icons.cloud_off, size: 48),
                const SizedBox(height: 12),
                const Text('Unable to load customers'),
                const SizedBox(height: 12),
                FilledButton.icon(
                  onPressed: () => setState(() => _future = _load()),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              ]),
            );
          }

          final customers = (snapshot.data ?? const <Map<String, dynamic>>[]).where((customer) {
            final q = _query.trim().toLowerCase();
            if (q.isEmpty) return true;
            return '${customer['name'] ?? ''} ${customer['phone'] ?? ''}'.toLowerCase().contains(q);
          }).toList();

          return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              const Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('Customers', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                  SizedBox(height: 4),
                  Text('Customer history and lifetime value from your orders'),
                ]),
              ),
              SizedBox(
                width: 260,
                child: TextField(
                  decoration: const InputDecoration(prefixIcon: Icon(Icons.search), hintText: 'Search customers'),
                  onChanged: (value) => setState(() => _query = value),
                ),
              ),
            ]),
            const SizedBox(height: 24),
            Expanded(
              child: Card(
                child: customers.isEmpty
                    ? const Center(child: Text('No customers found'))
                    : ListView.separated(
                        itemCount: customers.length,
                        separatorBuilder: (_, __) => const Divider(height: 1),
                        itemBuilder: (context, index) {
                          final customer = customers[index];
                          final sales = (customer['paid_sales'] as num?)?.toDouble() ?? 0;
                          return ListTile(
                            leading: CircleAvatar(child: Text('${customer['name'] ?? 'G'}'.trim().isEmpty ? 'G' : '${customer['name']}'.trim()[0].toUpperCase())),
                            title: Text('${customer['name'] ?? 'Guest'}'),
                            subtitle: Text([
                              if ((customer['phone'] ?? '').toString().isNotEmpty) '${customer['phone']}',
                              '${customer['orders'] ?? 0} orders',
                            ].join(' • ')),
                            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                              Text('₹${sales.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                              const Text('lifetime sales'),
                            ]),
                          );
                        },
                      ),
              ),
            ),
          ]);
        },
      ),
    );
  }
}
