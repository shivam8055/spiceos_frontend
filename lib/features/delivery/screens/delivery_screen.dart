import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/delivery.dart';

final deliveryProvidersProvider = FutureProvider<List<DeliveryProviderInfo>>((ref) async {
  final response = await ref.read(apiClientProvider).get('/delivery/providers');
  return (response.data as List)
      .map((item) => DeliveryProviderInfo.fromJson(Map<String, dynamic>.from(item as Map)))
      .toList();
});

final deliveryJobsProvider = FutureProvider<List<DeliveryJob>>((ref) async {
  final response = await ref.read(apiClientProvider).get('/delivery/jobs');
  return (response.data as List)
      .map((item) => DeliveryJob.fromJson(Map<String, dynamic>.from(item as Map)))
      .toList();
});

class DeliveryScreen extends ConsumerWidget {
  const DeliveryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(deliveryProvidersProvider);
    final jobs = ref.watch(deliveryJobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Network'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: () {
              ref.invalidate(deliveryProvidersProvider);
              ref.invalidate(deliveryJobsProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(deliveryProvidersProvider);
          ref.invalidate(deliveryJobsProvider);
          await Future.wait([
            ref.read(deliveryProvidersProvider.future),
            ref.read(deliveryJobsProvider.future),
          ]);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Provider Network', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            providers.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => _ErrorCard(message: error.toString()),
              data: (items) => Card(
                child: Column(
                  children: items.map((item) => ListTile(
                    leading: CircleAvatar(
                      child: Icon(item.configured ? Icons.check : Icons.lock_outline),
                    ),
                    title: Text(_providerName(item.provider)),
                    subtitle: Text(item.configured ? 'Ready' : (item.reason ?? 'Not configured')),
                    trailing: Chip(label: Text(item.configured ? 'ACTIVE' : 'SETUP')),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Text('Live Delivery Jobs', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            jobs.when(
              loading: () => const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator())),
              error: (error, _) => _ErrorCard(message: error.toString()),
              data: (items) => items.isEmpty
                  ? const Card(child: Padding(padding: EdgeInsets.all(24), child: Text('No delivery jobs yet.')))
                  : Column(children: items.map((job) => Card(
                      child: ListTile(
                        leading: const Icon(Icons.local_shipping_outlined),
                        title: Text('Order #${job.orderId} · ${_providerName(job.provider)}'),
                        subtitle: Text(job.status.replaceAll('_', ' ').toUpperCase()),
                        trailing: job.etaMinutes == null ? null : Text('${job.etaMinutes} min'),
                      ),
                    )).toList()),
            ),
          ],
        ),
      ),
    );
  }

  static String _providerName(String value) {
    switch (value) {
      case 'uber_direct': return 'Uber Direct';
      case 'rapido': return 'Rapido';
      case 'ola': return 'Ola';
      case 'own_agent': return 'SpiceOS Agent';
      default: return value;
    }
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard({required this.message});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text(message),
        ),
      );
}
