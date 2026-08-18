import 'package:flutter/material.dart';

import '../models/order.dart';

class OrderTimeline extends StatelessWidget {
  final Order order;

  const OrderTimeline({
    super.key,
    required this.order,
  });

  String _formatTime(DateTime value) {
    final local = value.toLocal();
    final hour = local.hour == 0 ? 12 : (local.hour > 12 ? local.hour - 12 : local.hour);
    final minute = local.minute.toString().padLeft(2, '0');
    final period = local.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  @override
  Widget build(BuildContext context) {
    final steps = <({String title, IconData icon, DateTime? time, bool complete})>[
      (
        title: 'Order placed',
        icon: Icons.receipt_long_outlined,
        time: order.createdAt,
        complete: true,
      ),
      (
        title: 'Cooking started',
        icon: Icons.restaurant_outlined,
        time: order.preparingAt,
        complete: order.preparingAt != null,
      ),
      (
        title: 'Ready',
        icon: Icons.check_circle_outline,
        time: order.readyAt,
        complete: order.readyAt != null,
      ),
      (
        title: 'Out for delivery',
        icon: Icons.delivery_dining_outlined,
        time: order.outForDeliveryAt,
        complete: order.outForDeliveryAt != null,
      ),
      (
        title: 'Delivered',
        icon: Icons.home_outlined,
        time: order.deliveredAt,
        complete: order.deliveredAt != null,
      ),
    ];

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Order timeline',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            const SizedBox(height: 16),
            for (var i = 0; i < steps.length; i++) ...[
              _TimelineRow(
                title: steps[i].title,
                icon: steps[i].icon,
                time: steps[i].time,
                complete: steps[i].complete,
                isCurrent: !steps[i].complete &&
                    ((order.status == OrderStatus.created && i == 1) ||
                        (order.status == OrderStatus.preparing && i == 2) ||
                        (order.status == OrderStatus.ready && i == 3) ||
                        (order.status == OrderStatus.outForDelivery && i == 4)),
                formatTime: _formatTime,
                showConnector: i < steps.length - 1,
              ),
            ],
            if (order.status == OrderStatus.cancelled) ...[
              const Divider(height: 24),
              Row(
                children: [
                  Icon(Icons.cancel_outlined, color: Theme.of(context).colorScheme.error),
                  const SizedBox(width: 8),
                  Text(
                    'Order cancelled',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _TimelineRow extends StatelessWidget {
  final String title;
  final IconData icon;
  final DateTime? time;
  final bool complete;
  final bool isCurrent;
  final String Function(DateTime) formatTime;
  final bool showConnector;

  const _TimelineRow({
    required this.title,
    required this.icon,
    required this.time,
    required this.complete,
    required this.isCurrent,
    required this.formatTime,
    required this.showConnector,
  });

  @override
  Widget build(BuildContext context) {
    final active = complete || isCurrent;
    final color = complete
        ? Theme.of(context).colorScheme.primary
        : isCurrent
            ? Theme.of(context).colorScheme.secondary
            : Colors.grey.shade400;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 32,
            child: Column(
              children: [
                Icon(icon, size: 20, color: color),
                if (showConnector)
                  Expanded(
                    child: Center(
                      child: Container(
                        width: 2,
                        color: active ? color.withValues(alpha: 0.45) : Colors.grey.shade300,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: TextStyle(
                        fontWeight: active ? FontWeight.w600 : FontWeight.normal,
                        color: active ? null : Colors.grey.shade500,
                      ),
                    ),
                  ),
                  if (time != null)
                    Text(
                      formatTime(time!),
                      style: TextStyle(
                        fontSize: 12,
                        color: active ? Colors.grey.shade700 : Colors.grey.shade500,
                      ),
                    )
                  else
                    Text(
                      'Pending',
                      style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
