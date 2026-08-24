import 'package:dio/dio.dart';
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
            tooltip: 'Refresh delivery data',
            onPressed: () => _refresh(ref),
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async => _refresh(ref),
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            Text('Provider Network', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 12),
            providers.when(
              loading: () => const LinearProgressIndicator(),
              error: (error, _) => _ErrorCard(_friendlyError(error)),
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
              error: (error, _) => _ErrorCard(_friendlyError(error)),
              data: (items) => items.isEmpty
                  ? const _ErrorCard('No delivery agents yet. Add an agent to start dispatching.')
                  : Card(
                      child: Column(
                        children: items.map((agent) => ListTile(
                          leading: CircleAvatar(child: Icon(Icons.delivery_dining)),
                          title: Text(agent.name),
                          subtitle: Text(agent.phone ?? 'No phone'),
                          trailing: OutlinedButton.icon(
                            onPressed: () => _showAgentStatusPicker(context, ref, agent),
                            icon: const Icon(Icons.swap_vert, size: 18),
                            label: Text(_statusLabel(agent.status)),
                            style: OutlinedButton.styleFrom(
                              visualDensity: VisualDensity.compact,
                            ),
                          ),
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
              error: (error, _) => _ErrorCard(_friendlyError(error)),
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

  static Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(deliveryProvidersProvider);
    ref.invalidate(deliveryAgentsProvider);
    ref.invalidate(deliveryJobsProvider);
  }

  static Future<void> _addAgent(BuildContext context, WidgetRef ref) async {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    bool saving = false;
    String? error;

    await showDialog<void>(
      context: context,
      barrierDismissible: !saving,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add delivery agent'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
              TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone')),
              if (error != null) ...[
                const SizedBox(height: 12),
                _InlineError(error!),
              ],
            ],
          ),
          actions: [
            TextButton(onPressed: saving ? null : () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(
              onPressed: saving
                  ? null
                  : () async {
                      if (nameController.text.trim().isEmpty) {
                        setState(() => error = 'Agent name is required.');
                        return;
                      }
                      setState(() {
                        saving = true;
                        error = null;
                      });
                      try {
                        await ref.read(apiClientProvider).post('/delivery/agents', {
                          'name': nameController.text.trim(),
                          'phone': phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                        });
                        ref.invalidate(deliveryAgentsProvider);
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                      } catch (e) {
                        setState(() {
                          saving = false;
                          error = _friendlyError(e);
                        });
                      }
                    },
              child: saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Create'),
            ),
          ],
        ),
      ),
    );

    nameController.dispose();
    phoneController.dispose();
  }

  static Future<void> _showAgentStatusPicker(BuildContext context, WidgetRef ref, DeliveryAgent agent) async {
    final selected = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('Set ${agent.name} status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _StatusOption(value: 'available', current: agent.status, icon: Icons.check_circle_outline, label: 'Available'),
            _StatusOption(value: 'busy', current: agent.status, icon: Icons.timelapse, label: 'Busy'),
            _StatusOption(value: 'offline', current: agent.status, icon: Icons.pause_circle_outline, label: 'Offline'),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
        ],
      ),
    );

    if (selected == null || selected == agent.status) return;
    await _setAgentStatus(context, ref, agent, selected);
  }

  static Future<void> _setAgentStatus(BuildContext context, WidgetRef ref, DeliveryAgent agent, String status) async {
    try {
      await ref.read(apiClientProvider).patch('/delivery/agents/${agent.id}', {'status': status});
      ref.invalidate(deliveryAgentsProvider);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${agent.name} is now ${_statusLabel(status)}.')),
        );
      }
    } catch (e) {
      if (context.mounted) _showError(context, _friendlyError(e));
    }
  }

  static Future<void> _dispatchOwnAgent(BuildContext context, WidgetRef ref) async {
    final orderController = TextEditingController();
    final addressController = TextEditingController();
    final pickupController = TextEditingController();
    DeliveryAgent? selectedAgent;
    String? error;
    bool dispatching = false;

    final agents = ref.read(deliveryAgentsProvider).valueOrNull ?? <DeliveryAgent>[];
    final availableAgents = agents.where((agent) => agent.status == 'available').toList();
    if (availableAgents.isNotEmpty) selectedAgent = availableAgents.first;

    await showDialog<void>(
      context: context,
      barrierDismissible: !dispatching,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Dispatch with SpiceOS Agent'),
          content: SizedBox(
            width: 420,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: orderController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Order ID', hintText: 'e.g. 12'),
                  ),
                  TextField(controller: pickupController, decoration: const InputDecoration(labelText: 'Pickup address')),
                  TextField(controller: addressController, decoration: const InputDecoration(labelText: 'Customer address')),
                  const SizedBox(height: 14),
                  if (availableAgents.isEmpty)
                    const _InlineError('No agent is Available. Set an agent to Available first.')
                  else
                    DropdownButtonFormField<DeliveryAgent>(
                      value: selectedAgent,
                      decoration: const InputDecoration(labelText: 'Delivery agent'),
                      items: availableAgents.map((agent) => DropdownMenuItem(
                        value: agent,
                        child: Text('${agent.name}${agent.phone == null ? '' : ' · ${agent.phone}'}'),
                      )).toList(),
                      onChanged: dispatching ? null : (value) => setState(() => selectedAgent = value),
                    ),
                  if (error != null) ...[
                    const SizedBox(height: 14),
                    _InlineError(error!),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: dispatching ? null : () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton.icon(
              onPressed: dispatching || availableAgents.isEmpty || selectedAgent == null
                  ? null
                  : () async {
                      final orderId = int.tryParse(orderController.text.trim());
                      final deliveryAddress = addressController.text.trim();
                      if (orderId == null) {
                        setState(() => error = 'Enter a valid numeric Order ID.');
                        return;
                      }
                      if (deliveryAddress.isEmpty) {
                        setState(() => error = 'Customer address is required.');
                        return;
                      }
                      setState(() {
                        dispatching = true;
                        error = null;
                      });
                      try {
                        final response = await ref.read(apiClientProvider).post('/delivery/jobs', {
                          'order_id': orderId,
                          'pickup_address': pickupController.text.trim().isEmpty ? null : pickupController.text.trim(),
                          'delivery_address': deliveryAddress,
                          'provider': 'own_agent',
                        });
                        final job = DeliveryJob.fromJson(Map<String, dynamic>.from(response.data as Map));

                        if (job.agentId == null && !{'delivered', 'cancelled'}.contains(job.status)) {
                          await ref.read(apiClientProvider).post('/delivery/jobs/${job.id}/assign', {
                            'agent_id': selectedAgent!.id,
                          });
                        }

                        ref.invalidate(deliveryAgentsProvider);
                        ref.invalidate(deliveryJobsProvider);
                        if (dialogContext.mounted) Navigator.pop(dialogContext);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Order #$orderId dispatched to ${selectedAgent!.name}.')),
                          );
                        }
                      } catch (e) {
                        setState(() {
                          dispatching = false;
                          error = _friendlyError(e);
                        });
                      }
                    },
              icon: dispatching
                  ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Icon(Icons.local_shipping),
              label: Text(dispatching ? 'Dispatching…' : 'Dispatch'),
            ),
          ],
        ),
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

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  static String _friendlyError(Object error) {
    if (error is DioException) {
      final data = error.response?.data;
      if (data is Map && data['detail'] != null) return data['detail'].toString();
      if (error.response?.statusCode != null) {
        return 'Delivery request failed (${error.response!.statusCode}). Please try again.';
      }
      if (error.type == DioExceptionType.connectionTimeout || error.type == DioExceptionType.receiveTimeout) {
        return 'The server took too long to respond. Please try again.';
      }
      return 'Could not reach the SpiceOS server. Please check the connection and try again.';
    }
    return error.toString().replaceFirst('Exception: ', '');
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

  static String _statusLabel(String status) {
    switch (status) {
      case 'available':
        return 'Available';
      case 'busy':
        return 'Busy';
      case 'offline':
        return 'Offline';
      default:
        return status.isEmpty ? 'Unknown' : status.toUpperCase();
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
      case 'assigned':
        return Icons.person_pin_circle;
      default:
        return Icons.schedule;
    }
  }
}

class _StatusOption extends StatelessWidget {
  final String value;
  final String current;
  final IconData icon;
  final String label;

  const _StatusOption({
    required this.value,
    required this.current,
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    final isCurrent = value == current;
    return ListTile(
      enabled: true,
      leading: Icon(icon),
      title: Text(label),
      trailing: isCurrent ? const Icon(Icons.check) : null,
      onTap: () => Navigator.pop(context, value),
    );
  }
}

class _InlineError extends StatelessWidget {
  final String message;
  const _InlineError(this.message);

  @override
  Widget build(BuildContext context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(message, style: TextStyle(color: Theme.of(context).colorScheme.onErrorContainer)),
      );
}

class _ErrorCard extends StatelessWidget {
  final String message;
  const _ErrorCard(this.message);

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(padding: const EdgeInsets.all(20), child: Text(message)),
      );
}
