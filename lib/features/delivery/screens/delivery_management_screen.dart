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

final deliveryAgentsProvider = FutureProvider<List<DeliveryAgent>>((ref) async {
  final response = await ref.read(apiClientProvider).get('/delivery/agents');
  return (response.data as List)
      .map((item) => DeliveryAgent.fromJson(Map<String, dynamic>.from(item as Map)))
      .toList();
});

final deliveryJobsProvider = FutureProvider<List<DeliveryJob>>((ref) async {
  final response = await ref.read(apiClientProvider).get('/delivery/jobs');
  return (response.data as List)
      .map((item) => DeliveryJob.fromJson(Map<String, dynamic>.from(item as Map)))
      .toList();
});

class DeliveryManagementScreen extends ConsumerWidget {
  const DeliveryManagementScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(deliveryProvidersProvider);
    final agents = ref.watch(deliveryAgentsProvider);
    final jobs = ref.watch(deliveryJobsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Network'),
        actions: [
          IconButton(
            onPressed: () {
              ref.invalidate(deliveryProvidersProvider);
              ref.invalidate(deliveryAgentsProvider);
              ref.invalidate(deliveryJobsProvider);
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(deliveryProvidersProvider);
          ref.invalidate(deliveryAgentsProvider);
          ref.invalidate(deliveryJobsProvider);
        },
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Provider Network', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            providers.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => _ErrorCard(error.toString()),
              data: (items) => Card(
                child: Column(
                  children: items.map((item) => ListTile(
                    leading: CircleAvatar(
                      child: Icon(item.configured ? Icons.check : Icons.lock_outline),
                    ),
                    title: Text(_providerName(item.provider)),
                    subtitle: Text(item.configured ? 'Ready' : (item.reason ?? 'Not configured')),
                    trailing: TextButton(
                      onPressed: () => _showProviderInfo(context, item),
                      child: Text(item.configured ? 'INFO' : 'SETUP'),
                    ),
                  )).toList(),
                ),
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: Text('Own Delivery Agents', style: Theme.of(context).textTheme.headlineSmall),
                ),
                FilledButton.icon(
                  onPressed: () => _addAgent(context, ref),
                  icon: const Icon(Icons.person_add),
                  label: const Text('Add agent'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            agents.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => _ErrorCard(error.toString()),
              data: (items) => items.isEmpty
                  ? const _ErrorCard('No delivery agents yet.')
                  : Card(
                      child: Column(
                        children: items.map((agent) => ListTile(
                          leading: const CircleAvatar(child: Icon(Icons.delivery_dining)),
                          title: Text(agent.name),
                          subtitle: Text(agent.phone ?? 'No phone'),
                          trailing: Text(agent.status.toUpperCase()),
                        )).toList(),
                      ),
                    ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                Expanded(
                  child: Text('Live Delivery Jobs', style: Theme.of(context).textTheme.headlineSmall),
                ),
                FilledButton.icon(
                  onPressed: () => _dispatchOwnAgent(context, ref),
                  icon: const Icon(Icons.local_shipping),
                  label: const Text('Dispatch'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            jobs.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, _) => _ErrorCard(error.toString()),
              data: (items) => items.isEmpty
                  ? const _ErrorCard('No delivery jobs yet.')
                  : Column(
                      children: items.map((job) => Card(
                        child: ListTile(
                          leading: Icon(_statusIcon(job.status)),
                          title: Text('Order #${job.orderId} · ${_providerName(job.provider)}'),
                          subtitle: Text(job.status.replaceAll('_', ' ').toUpperCase()),
                          trailing: job.etaMinutes == null ? null : Text('${job.etaMinutes} min'),
                        ),
                      )).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  static Future<void> _addAgent(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Add delivery agent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
            TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              if (nameController.text.trim().isEmpty) return;
              await ref.read(apiClientProvider).post('/delivery/agents', {
                'name': nameController.text.trim(),
                'phone': phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
              });
              ref.invalidate(deliveryAgentsProvider);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );

    nameController.dispose();
    phoneController.dispose();
  }

  static Future<void> _dispatchOwnAgent(BuildContext context, WidgetRef ref) async {
    final orderController = TextEditingController();
    final addressController = TextEditingController();
    final pickupController = TextEditingController();

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Dispatch with SpiceOS Agent'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: orderController, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Order ID')),
            TextField(controller: pickupController, decoration: const InputDecoration(labelText: 'Pickup address')),
            TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Customer address')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
          FilledButton(
            onPressed: () async {
              final orderId = int.tryParse(orderController.text.trim());
              if (orderId == null || addressController.text.trim().isEmpty) return;
              await ref.read(apiClientProvider).post('/delivery/jobs', {
                'order_id': orderId,
                'pickup_address': pickupController.text.trim().isEmpty ? null : pickupController.text.trim(),
                'delivery_address': addressController.text.trim(),
                'provider': 'own_agent',
              });
              ref.invalidate(deliveryJobsProvider);
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
            child: const Text('Dispatch'),
          ),
        ],
      ),
    );

    orderController.dispose();
    addressController.dispose();
    pickupController.dispose();
  }

  static void _showProviderInfo(BuildContext context, DeliveryProviderInfo item) {
    String message;
    if (item.configured) {
      message = '${_providerName(item.provider)} is configured and ready.';
    } else if (item.provider == 'uber_direct') {
      message = 'Configure these Railway backend variables:\n\nUBER_DIRECT_CLIENT_ID\nUBER_DIRECT_CLIENT_SECRET\nUBER_DIRECT_CUSTOMER_ID\nUBER_DIRECT_WEBHOOK_SECRET\nUBER_DIRECT_PICKUP_NAME\nUBER_DIRECT_PICKUP_PHONE\n\nWebhook endpoint: /webhooks/delivery/uber';
    } else {
      message = '${_providerName(item.provider)} requires official partner/API credentials. SpiceOS will not use undocumented/private APIs.';
    }

    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(_providerName(item.provider)),
        content: Text(message),
        actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))],
      ),
    );
  }

  static String _providerName(String value) {
    switch (value) {
      case 'uber_direct':
        return 'Uber Direct';
      case 'rapido':
        return 'Rapido';
      case 'ola':
        return 'Ola';
      case 'own_agent':
        return 'SpiceOS Agent';
      default:
        return value;
    }
  }

  static IconData _statusIcon(String status) {
    switch (status) {
      case 'delivered':
        return Icons.check_circle;
      case 'cancelled':
        return Icons.cancel;
      case 'failed':
        return Icons.error_outline;
      case 'out_for_delivery':
        return Icons.local_shipping;
      default:
        return Icons.schedule;
    }
  }
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard(this.message);

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(padding: const EdgeInsets.all(20), child: Text(message)),
      );
}
