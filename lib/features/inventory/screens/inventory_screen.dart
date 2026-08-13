import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/app_shell.dart';
import '../models/inventory_api_item.dart';
import '../models/inventory_movement_api_item.dart';
import '../providers/inventory_api_provider.dart';
import '../widgets/add_inventory_item_dialog.dart';

class InventoryScreen extends ConsumerWidget {
  const InventoryScreen({super.key});

  Future<void> _showAddItem(BuildContext context) async {
    await showDialog<bool>(
      context: context,
      builder: (_) => const AddInventoryItemDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryItemsProvider);

    return AppShell(
      child: inventory.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => _InventoryError(
          message: error.toString(),
          onRetry: () => ref.invalidate(inventoryItemsProvider),
        ),
        data: (items) => RefreshIndicator(
          onRefresh: () async => ref.invalidate(inventoryItemsProvider),
          child: _InventoryContent(
            items: items,
            ref: ref,
            onAddItem: () => _showAddItem(context),
          ),
        ),
      ),
    );
  }
}

class _InventoryContent extends StatelessWidget {
  const _InventoryContent({required this.items, required this.ref, required this.onAddItem});

  final List<InventoryApiItem> items;
  final WidgetRef ref;
  final VoidCallback onAddItem;

  @override
  Widget build(BuildContext context) {
    final lowStock = items.where((item) => item.isLowStock).length;
    final outOfStock = items.where((item) => item.isOutOfStock).length;
    final stockValue = items.fold<double>(0, (sum, item) => sum + item.stockValue);

    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Inventory', style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Track ingredients, stock levels and reorder risk.', style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              OutlinedButton.icon(onPressed: onAddItem, icon: const Icon(Icons.add), label: const Text('Add Item')),
            ],
          ),
          const SizedBox(height: 24),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final columns = width >= 1100 ? 4 : width >= 700 ? 2 : 1;
              final cardWidth = (width - ((columns - 1) * 16)) / columns;
              return Wrap(
                spacing: 16,
                runSpacing: 16,
                children: [
                  _MetricCard(width: cardWidth, title: 'Total Items', value: '${items.length}', icon: Icons.inventory_2_outlined),
                  _MetricCard(width: cardWidth, title: 'Low Stock', value: '$lowStock', icon: Icons.warning_amber_rounded),
                  _MetricCard(width: cardWidth, title: 'Out of Stock', value: '$outOfStock', icon: Icons.remove_shopping_cart_outlined),
                  _MetricCard(width: cardWidth, title: 'Stock Value', value: '₹${stockValue.toStringAsFixed(0)}', icon: Icons.currency_rupee),
                ],
              );
            },
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: const Color(0xFFE5E7EB))),
            child: items.isEmpty
                ? const Padding(padding: EdgeInsets.all(48), child: Center(child: Text('No inventory items yet.')))
                : _InventoryTable(items: items, ref: ref),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.width, required this.title, required this.value, required this.icon});
  final double width;
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(12)),
                child: Icon(icon, color: Theme.of(context).colorScheme.primary),
              ),
              const SizedBox(width: 14),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(title, style: Theme.of(context).textTheme.bodySmall),
                const SizedBox(height: 4),
                Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700)),
              ]),
            ],
          ),
        ),
      ),
    );
  }
}

class _InventoryTable extends StatelessWidget {
  const _InventoryTable({required this.items, required this.ref});
  final List<InventoryApiItem> items;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 34,
        headingRowHeight: 52,
        dataRowMinHeight: 64,
        dataRowMaxHeight: 76,
        columns: const [
          DataColumn(label: Text('Item')),
          DataColumn(label: Text('SKU')),
          DataColumn(label: Text('Stock')),
          DataColumn(label: Text('Reorder Level')),
          DataColumn(label: Text('Cost / Unit')),
          DataColumn(label: Text('Status')),
          DataColumn(label: Text('Actions')),
        ],
        rows: items.map((item) {
          final status = item.isOutOfStock ? 'Out of stock' : item.isLowStock ? 'Low stock' : 'Healthy';
          return DataRow(cells: [
            DataCell(Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600))),
            DataCell(Text(item.sku ?? '—')),
            DataCell(Text('${_format(item.quantity)} ${item.unit}')),
            DataCell(Text('${_format(item.reorderLevel)} ${item.unit}')),
            DataCell(Text('₹${item.costPerUnit.toStringAsFixed(2)}')),
            DataCell(_StatusChip(label: status, item: item)),
            DataCell(Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(tooltip: 'Adjust stock', icon: const Icon(Icons.tune, size: 20), onPressed: () => _showAdjustDialog(context, item)),
              IconButton(tooltip: 'Movement history', icon: const Icon(Icons.history, size: 20), onPressed: () => _showMovementDialog(context, item)),
            ])),
          ]);
        }).toList(),
      ),
    );
  }

  Future<void> _showAdjustDialog(BuildContext context, InventoryApiItem item) async {
    await showDialog<bool>(context: context, builder: (_) => _AdjustInventoryDialog(item: item, ref: ref));
  }

  Future<void> _showMovementDialog(BuildContext context, InventoryApiItem item) async {
    await showDialog<void>(context: context, builder: (_) => _MovementHistoryDialog(item: item, ref: ref));
  }

  static String _format(double value) => value == value.roundToDouble() ? value.toStringAsFixed(0) : value.toStringAsFixed(2);
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.item});
  final String label;
  final InventoryApiItem item;

  @override
  Widget build(BuildContext context) {
    final color = item.isOutOfStock ? Colors.red : item.isLowStock ? Colors.orange : Colors.green;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(20)),
      child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 12)),
    );
  }
}

class _AdjustInventoryDialog extends ConsumerStatefulWidget {
  const _AdjustInventoryDialog({required this.item, required this.ref});
  final InventoryApiItem item;
  final WidgetRef ref;

  @override
  ConsumerState<_AdjustInventoryDialog> createState() => _AdjustInventoryDialogState();
}

class _AdjustInventoryDialogState extends ConsumerState<_AdjustInventoryDialog> {
  final _quantityController = TextEditingController();
  final _reasonController = TextEditingController();
  bool _saving = false;
  bool _add = true;

  @override
  void dispose() {
    _quantityController.dispose();
    _reasonController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final quantity = double.tryParse(_quantityController.text.trim());
    final reason = _reasonController.text.trim();
    if (quantity == null || quantity <= 0 || reason.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter a valid quantity and reason.')));
      return;
    }
    final delta = _add ? quantity : -quantity;
    if (!_add && quantity > widget.item.quantity) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Cannot remove more stock than available.')));
      return;
    }

    setState(() => _saving = true);
    try {
      await adjustInventory(widget.ref, itemId: widget.item.id, quantityDelta: delta, reason: reason);
      if (mounted) Navigator.of(context).pop(true);
    } on DioException catch (error) {
      final message = error.response?.data is Map<String, dynamic>
          ? (error.response?.data['detail']?.toString() ?? 'Unable to adjust stock.')
          : 'Unable to adjust stock.';
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to adjust stock: $error')));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Adjust ${widget.item.name}'),
      content: SizedBox(
        width: 420,
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(
  'Current stock: ${widget.item.quantity.toStringAsFixed(2)} ${widget.item.unit}',
),
          const SizedBox(height: 18),
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(value: true, label: Text('Stock In'), icon: Icon(Icons.add)),
              ButtonSegment(value: false, label: Text('Stock Out'), icon: Icon(Icons.remove)),
            ],
            selected: {_add},
            onSelectionChanged: _saving ? null : (value) => setState(() => _add = value.first),
          ),
          const SizedBox(height: 18),
          TextField(controller: _quantityController, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: 'Quantity (${widget.item.unit})', border: const OutlineInputBorder())),
          const SizedBox(height: 14),
          TextField(controller: _reasonController, maxLength: 255, decoration: const InputDecoration(labelText: 'Reason', hintText: 'Purchase, wastage, correction...', border: OutlineInputBorder())),
        ]),
      ),
      actions: [
        TextButton(onPressed: _saving ? null : () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: _saving ? null : _save, child: _saving ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Save Adjustment')),
      ],
    );
  }
}

class _MovementHistoryDialog extends StatelessWidget {
  const _MovementHistoryDialog({required this.item, required this.ref});
  final InventoryApiItem item;
  final WidgetRef ref;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('${item.name} — Movement History'),
      content: SizedBox(
        width: 560,
        height: 420,
        child: FutureBuilder<List<InventoryMovementApiItem>>(
          future: getInventoryMovements(ref, item.id),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
            if (snapshot.hasError) return Center(child: Text('Unable to load movement history.\n${snapshot.error}', textAlign: TextAlign.center));
            final movements = snapshot.data ?? const <InventoryMovementApiItem>[];
            if (movements.isEmpty) return const Center(child: Text('No stock movements recorded yet.'));
            return ListView.separated(
              itemCount: movements.length,
              separatorBuilder: (_, _) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final movement = movements[index];
                final isIn = movement.quantityDelta > 0;
                final sign = isIn ? '+' : '';
                return ListTile(
                  leading: CircleAvatar(radius: 18, child: Icon(isIn ? Icons.arrow_downward : Icons.arrow_upward, size: 18)),
                  title: Text(
  '$sign${movement.quantityDelta.toStringAsFixed(2)} ${item.unit}', style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(movement.reason),
                  trailing: Text(_formatDate(movement.createdAt)),
                );
              },
            );
          },
        ),
      ),
      actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
    );
  }

  static String _formatDate(DateTime date) => '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
}

class _InventoryError extends StatelessWidget {
  const _InventoryError({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.cloud_off_outlined, size: 48),
          const SizedBox(height: 16),
          const Text('Unable to load inventory', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          Text(message, textAlign: TextAlign.center, maxLines: 4, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 16),
          FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Retry')),
        ]),
      ),
    );
  }
}
