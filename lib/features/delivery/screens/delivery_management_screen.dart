import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/delivery.dart';

final deliveryProvidersProvider = FutureProvider<List<DeliveryProviderInfo>>((ref) async {
  final response = await ref.read(apiClientProvider).get('/delivery/providers');
  return (response.data as List).map((e) => DeliveryProviderInfo.fromJson(Map<String, dynamic>.from(e as Map))).toList();
});
final deliveryAgentsProvider = FutureProvider<List<DeliveryAgent>>((ref) async {
  final response = await ref.read(apiClientProvider).get('/delivery/agents');
  return (response.data as List).map((e) => DeliveryAgent.fromJson(Map<String, dynamic>.from(e as Map))).toList();
});
final deliveryJobsProvider = FutureProvider<List<DeliveryJob>>((ref) async {
  final response = await ref.read(apiClientProvider).get('/delivery/jobs');
  return (response.data as List).map((e) => DeliveryJob.fromJson(Map<String, dynamic>.from(e as Map))).toList();
});

class DeliveryManagementScreen extends ConsumerWidget {
  const DeliveryManagementScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(deliveryProvidersProvider);
    ref.invalidate(deliveryAgentsProvider);
    ref.invalidate(deliveryJobsProvider);
    await Future.wait([
      ref.read(deliveryProvidersProvider.future),
      ref.read(deliveryAgentsProvider.future),
      ref.read(deliveryJobsProvider.future),
    ]);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providers = ref.watch(deliveryProvidersProvider);
    final agents = ref.watch(deliveryAgentsProvider);
    final jobs = ref.watch(deliveryJobsProvider);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Delivery Network'),
        actions: [
          IconButton(onPressed: () => _refresh(ref), icon: const Icon(Icons.refresh)),
          FilledButton.icon(onPressed: () => _dispatch(context, ref), icon: const Icon(Icons.local_shipping), label: const Text('Dispatch')),
          const SizedBox(width: 12),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => _refresh(ref),
        child: ListView(padding: const EdgeInsets.all(20), children: [
          Text('Provider Network', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          providers.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => _CardText(e.toString()),
            data: (items) => Card(child: Column(children: items.map((p) => ListTile(
              leading: CircleAvatar(child: Icon(p.configured ? Icons.check : Icons.lock_outline)),
              title: Text(_name(p.provider)),
              subtitle: Text(p.configured ? 'Ready' : (p.reason ?? 'Not configured')),
              trailing: OutlinedButton(onPressed: () => _setup(context, p), child: Text(p.configured ? 'INFO' : 'SETUP')),
            )).toList())),
          ),
          const SizedBox(height: 28),
          Row(children: [Expanded(child: Text('Own Delivery Agents', style: Theme.of(context).textTheme.headlineSmall)), FilledButton.icon(onPressed: () => _addAgent(context, ref), icon: const Icon(Icons.person_add), label: const Text('Add agent'))]),
          const SizedBox(height: 12),
          agents.when(
            loading: () => const LinearProgressIndicator(),
            error: (e, _) => _CardText(e.toString()),
            data: (items) => items.isEmpty ? const _CardText('No delivery agents yet.') : Card(child: Column(children: items.map((a) => ListTile(
              leading: const CircleAvatar(child: Icon(Icons.delivery_dining)),
              title: Text(a.name), subtitle: Text(a.phone ?? 'No phone'),
              trailing: DropdownButton<String>(value: a.status, items: const [
                DropdownMenuItem(value: 'offline', child: Text('Offline')),
                DropdownMenuItem(value: 'available', child: Text('Available')),
                DropdownMenuItem(value: 'busy', child: Text('Busy')),
              ], onChanged: (v) async { if (v == null) return; await ref.read(apiClientProvider).patch('/delivery/agents/${a.id}', {'status': v}); ref.invalidate(deliveryAgentsProvider); }),
            )).toList())),
          ),
          const SizedBox(height: 28),
          Text('Live Delivery Jobs', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 12),
          jobs.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _CardText(e.toString()),
            data: (items) => items.isEmpty ? const _CardText('No delivery jobs yet.') : Column(children: items.map((j) => Card(child: ListTile(
              leading: Icon(_icon(j.status)), title: Text('Order #${j.orderId} · ${_name(j.provider)}'),
              subtitle: Text(j.status.replaceAll('_', ' ').toUpperCase()),
              trailing: Row(mainAxisSize: MainAxisSize.min, children: [if (j.etaMinutes != null) Text('${j.etaMinutes} min'), IconButton(onPressed: () async { await ref.read(apiClientProvider).post('/delivery/jobs/${j.id}/refresh'); ref.invalidate(deliveryJobsProvider); }, icon: const Icon(Icons.sync)), if (!{'delivered', 'cancelled'}.contains(j.status)) IconButton(onPressed: () async { await ref.read(apiClientProvider).post('/delivery/jobs/${j.id}/cancel'); ref.invalidate(deliveryJobsProvider); }, icon: const Icon(Icons.cancel_outlined))]),
            ))).toList()),
          ),
        ]),
      ),
    );
  }

  static Future<void> _addAgent(BuildContext context, WidgetRef ref) async {
    final name = TextEditingController(), phone = TextEditingController();
    final ok = await showDialog<bool>(context: context, builder: (c) => AlertDialog(title: const Text('Add delivery agent'), content: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: name, decoration: const InputDecoration(labelText: 'Name')), TextField(controller: phone, decoration: const InputDecoration(labelText: 'Phone'))]), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')), FilledButton(onPressed: () async { if (name.text.trim().isEmpty) return; await ref.read(apiClientProvider).post('/delivery/agents', {'name': name.text.trim(), 'phone': phone.text.trim().isEmpty ? null : phone.text.trim()}); if (c.mounted) Navigator.pop(c, true); }, child: const Text('Create'))]));
    name.dispose(); phone.dispose(); if (ok == true) ref.invalidate(deliveryAgentsProvider);
  }

  static Future<void> _dispatch(BuildContext context, WidgetRef ref) async {
    final order = TextEditingController(), pickup = TextEditingController(), address = TextEditingController(), customer = TextEditingController(), phone = TextEditingController();
    String provider = 'own_agent';
    final ok = await showDialog<bool>(context: context, builder: (dialog) => StatefulBuilder(builder: (c, setState) => AlertDialog(title: const Text('Dispatch delivery'), content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [TextField(controller: order, keyboardType: TextInputType.number, decoration: const InputDecoration(labelText: 'Order ID')), TextField(controller: pickup, decoration: const InputDecoration(labelText: 'Pickup address')), TextField(controller: address, decoration: const InputDecoration(labelText: 'Customer address')), TextField(controller: customer, decoration: const InputDecoration(labelText: 'Customer name')), TextField(controller: phone, decoration: const InputDecoration(labelText: 'Customer phone')), DropdownButtonFormField<String>(value: provider, decoration: const InputDecoration(labelText: 'Provider'), items: const [DropdownMenuItem(value: 'own_agent', child: Text('SpiceOS Agent')), DropdownMenuItem(value: 'uber_direct', child: Text('Uber Direct')), DropdownMenuItem(value: 'rapido', child: Text('Rapido')), DropdownMenuItem(value: 'ola', child: Text('Ola'))], onChanged: (v) => setState(() => provider = v ?? 'own_agent'))])), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Cancel')), FilledButton(onPressed: () async { final id = int.tryParse(order.text.trim()); if (id == null || address.text.trim().isEmpty) return; await ref.read(apiClientProvider).post('/delivery/jobs', {'order_id': id, 'pickup_address': pickup.text.trim().isEmpty ? null : pickup.text.trim(), 'delivery_address': address.text.trim(), 'customer_name': customer.text.trim().isEmpty ? null : customer.text.trim(), 'customer_phone': phone.text.trim().isEmpty ? null : phone.text.trim(), 'provider': provider}); if (c.mounted) Navigator.pop(c, true); }, child: const Text('Dispatch'))]));
    order.dispose(); pickup.dispose(); address.dispose(); customer.dispose(); phone.dispose(); if (ok == true) ref.invalidate(deliveryJobsProvider);
  }

  static void _setup(BuildContext context, DeliveryProviderInfo p) {
    final text = p.configured ? '${_name(p.provider)} is configured and ready.' : p.provider == 'uber_direct' ? 'Add to Railway backend variables:\n\nUBER_DIRECT_CLIENT_ID\nUBER_DIRECT_CLIENT_SECRET\nUBER_DIRECT_CUSTOMER_ID\nUBER_DIRECT_WEBHOOK_SECRET\nUBER_DIRECT_PICKUP_NAME\nUBER_DIRECT_PICKUP_PHONE\n\nWebhook endpoint: /webhooks/delivery/uber' : '${_name(p.provider)} needs an official partner/API contract and credentials. SpiceOS will not use undocumented/private APIs.';
    showDialog<void>(context: context, builder: (c) => AlertDialog(title: Text(_name(p.provider)), content: Text(text), actions: [TextButton(onPressed: () => Navigator.pop(c), child: const Text('Close'))]));
  }

  static String _name(String p) => {'uber_direct': 'Uber Direct', 'rapido': 'Rapido', 'ola': 'Ola', 'own_agent': 'SpiceOS Agent'}[p] ?? p;
  static IconData _icon(String s) => s == 'delivered' ? Icons.check_circle : s == 'cancelled' ? Icons.cancel : s == 'out_for_delivery' ? Icons.local_shipping : Icons.schedule;
}

class _CardText extends StatelessWidget {
  final String text;
  const _CardText(this.text);
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(20), child: Text(text)));
}
