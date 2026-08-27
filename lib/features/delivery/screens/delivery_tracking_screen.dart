import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';

class DeliveryTrackingScreen extends ConsumerStatefulWidget {
  const DeliveryTrackingScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<DeliveryTrackingScreen> createState() => _DeliveryTrackingScreenState();
}

class _DeliveryTrackingScreenState extends ConsumerState<DeliveryTrackingScreen> {
  Map<String, dynamic>? _data;
  String? _error;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
    _timer = Timer.periodic(const Duration(seconds: 10), (_) => _load());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final response = await ref.read(apiClientProvider).get('/delivery/public/${widget.token}');
      if (!mounted) return;
      setState(() {
        _data = Map<String, dynamic>.from(response.data as Map);
        _error = null;
      });
      final status = _data?['status']?.toString();
      if (status == 'delivered' || status == 'cancelled' || status == 'failed') {
        _timer?.cancel();
      }
    } on DioException catch (error) {
      if (!mounted) return;
      final detail = error.response?.data is Map
          ? error.response?.data['detail']?.toString()
          : null;
      setState(() => _error = detail ?? 'Unable to load delivery tracking.');
    } catch (_) {
      if (mounted) setState(() => _error = 'Unable to load delivery tracking.');
    }
  }

  String _label(String status) {
    switch (status) {
      case 'created':
        return 'Order received';
      case 'dispatching':
        return 'Finding a delivery partner';
      case 'assigned':
        return 'Delivery partner assigned';
      case 'picked_up':
        return 'Picked up from restaurant';
      case 'out_for_delivery':
        return 'Out for delivery';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      case 'failed':
        return 'Delivery failed';
      default:
        return status.replaceAll('_', ' ');
    }
  }

  int _step(String status) {
    switch (status) {
      case 'created':
        return 0;
      case 'dispatching':
        return 1;
      case 'assigned':
        return 2;
      case 'picked_up':
        return 3;
      case 'out_for_delivery':
        return 4;
      case 'delivered':
        return 5;
      default:
        return 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = _data;
    final status = data?['status']?.toString() ?? 'created';
    final eta = data?['eta_minutes'];
    final trackingUrl = data?['tracking_url']?.toString();
    final lat = data?['latitude'];
    final lng = data?['longitude'];
    final active = !{'delivered', 'cancelled', 'failed'}.contains(status);

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        title: const Text('Track Delivery', style: TextStyle(fontWeight: FontWeight.w800)),
        actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))],
      ),
      body: _error != null && data == null
          ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!)))
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.all(18),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Delivery status', style: TextStyle(color: Colors.grey)),
                          const SizedBox(height: 6),
                          Text(_label(status), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
                          if (eta != null) ...[
                            const SizedBox(height: 8),
                            Text('Estimated time: $eta min', style: const TextStyle(fontWeight: FontWeight.w600)),
                          ],
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: List.generate(6, (index) {
                          final labels = const [
                            'Order received',
                            'Dispatching',
                            'Assigned',
                            'Picked up',
                            'Out for delivery',
                            'Delivered',
                          ];
                          final current = _step(status);
                          final done = index <= current && !{'cancelled', 'failed'}.contains(status);
                          return Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Column(
                                children: [
                                  CircleAvatar(
                                    radius: 13,
                                    child: Icon(done ? Icons.check : Icons.circle_outlined, size: 15),
                                  ),
                                  if (index < 5) Container(width: 2, height: 30, color: Theme.of(context).dividerColor),
                                ],
                              ),
                              const SizedBox(width: 12),
                              Padding(padding: const EdgeInsets.only(top: 4), child: Text(labels[index], style: TextStyle(fontWeight: done ? FontWeight.w700 : FontWeight.w400))),
                            ],
                          );
                        }),
                      ),
                    ),
                  ),
                  if (trackingUrl != null && trackingUrl.isNotEmpty) ...[
                    const SizedBox(height: 12),
                    Card(child: ListTile(leading: const Icon(Icons.map_outlined), title: const Text('Live tracking available'), subtitle: Text(trackingUrl))),
                  ],
                  if (lat != null && lng != null) ...[
                    const SizedBox(height: 12),
                    Card(child: ListTile(leading: const Icon(Icons.location_on_outlined), title: const Text('Latest location'), subtitle: Text('${lat.toString()}, ${lng.toString()}'))),
                  ],
                  if (active) ...[
                    const SizedBox(height: 14),
                    const Center(child: Text('This page updates automatically every 10 seconds.', style: TextStyle(color: Colors.grey))),
                  ],
                ],
              ),
            ),
    );
  }
}
