import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/qr_menu.dart';
import '../providers/qr_ordering_provider.dart';

class QROrderingScreen extends ConsumerStatefulWidget {
  const QROrderingScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<QROrderingScreen> createState() => _QROrderingScreenState();
}

class _QROrderingScreenState extends ConsumerState<QROrderingScreen> {
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  String? _category;

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(qrOrderingProvider(widget.token));
    final notifier = ref.read(qrOrderingProvider(widget.token).notifier);

    if (state.confirmation != null) {
      return _ConfirmationView(state: state, onRefresh: notifier.refreshStatus);
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: state.loading
                ? const Center(child: Padding(padding: EdgeInsets.all(80), child: CircularProgressIndicator()))
                : state.menu == null
                    ? _ErrorView(message: state.error ?? 'Unable to load this menu.', onRetry: notifier.loadMenu)
                    : _MenuView(
                        state: state,
                        selectedCategory: _category,
                        onCategoryChanged: (value) => setState(() => _category = value),
                        onAdd: (item) => _addItem(context, item, notifier),
                        onOpenCart: () => _showCart(context, state, notifier),
                      ),
          ),
        ),
      ),
      bottomNavigationBar: state.menu == null || state.cart.isEmpty
          ? null
          : SafeArea(
              minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: FilledButton(
                onPressed: () => _showCart(context, state, notifier),
                style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('${state.cartCount} ${state.cartCount == 1 ? 'item' : 'items'}'),
                    const SizedBox(width: 12),
                    Text('₹${state.cartTotal.toStringAsFixed(0)}'),
                    const SizedBox(width: 8),
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
    );
  }

  Future<void> _addItem(BuildContext context, QRMenuItem item, QROrderingNotifier notifier) async {
    if (item.modifiers.where((modifier) => modifier.available).isEmpty) {
      notifier.addToCart(item);
      return;
    }
    final selected = <QRModifier>[];
    final noteController = TextEditingController();
    final result = await showModalBottomSheet<_ItemSelection>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => StatefulBuilder(
        builder: (context, setSheetState) {
          final availableModifiers = item.modifiers.where((modifier) => modifier.available).toList();
          return Padding(
            padding: EdgeInsets.fromLTRB(20, 8, 20, MediaQuery.of(context).viewInsets.bottom + 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(item.name, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 6),
                Text('₹${item.price.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 18),
                ...availableModifiers.map(
                  (modifier) => CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: selected.any((selectedModifier) => selectedModifier.id == modifier.id),
                    title: Text(modifier.name),
                    subtitle: Text(modifier.priceDelta >= 0 ? '+₹${modifier.priceDelta.toStringAsFixed(0)}' : '-₹${modifier.priceDelta.abs().toStringAsFixed(0)}'),
                    onChanged: (value) => setSheetState(() {
                      if (value == true) {
                        selected.add(modifier);
                      } else {
                        selected.removeWhere((entry) => entry.id == modifier.id);
                      }
                    }),
                  ),
                ),
                TextField(controller: noteController, maxLength: 500, decoration: const InputDecoration(labelText: 'Special note (optional)', prefixIcon: Icon(Icons.notes_outlined))),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: () => Navigator.pop(context, _ItemSelection(modifiers: List.of(selected), note: noteController.text)),
                    child: const Text('Add to cart'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
    noteController.dispose();
    if (result != null) notifier.addToCart(item, modifiers: result.modifiers, note: result.note);
  }

  Future<void> _showCart(BuildContext context, QROrderingState state, QROrderingNotifier notifier) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => _CartSheet(
        state: state,
        notifier: notifier,
        nameController: _nameController,
        phoneController: _phoneController,
      ),
    );
  }
}

class _ItemSelection {
  const _ItemSelection({required this.modifiers, required this.note});
  final List<QRModifier> modifiers;
  final String note;
}

class _MenuView extends StatelessWidget {
  const _MenuView({required this.state, required this.selectedCategory, required this.onCategoryChanged, required this.onAdd, required this.onOpenCart});
  final QROrderingState state;
  final String? selectedCategory;
  final ValueChanged<String?> onCategoryChanged;
  final ValueChanged<QRMenuItem> onAdd;
  final VoidCallback onOpenCart;

  @override
  Widget build(BuildContext context) {
    final menu = state.menu!;
    final category = selectedCategory ?? (menu.categories.isNotEmpty ? menu.categories.first : null);
    final items = category == null ? menu.items : menu.items.where((item) => item.category == category).toList();

    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Container(width: 42, height: 42, decoration: BoxDecoration(color: Theme.of(context).colorScheme.primary, borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.restaurant_rounded, color: Colors.white)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('SpiceOS', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
                  Text(menu.tableName, style: Theme.of(context).textTheme.bodySmall),
                ])),
                if (state.cart.isNotEmpty) IconButton(onPressed: onOpenCart, icon: Badge(label: Text('${state.cartCount}'), child: const Icon(Icons.shopping_bag_outlined))),
              ]),
              const SizedBox(height: 22),
              Text('Order at your table', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text('Freshly prepared. Delivered to ${menu.tableName}.', style: Theme.of(context).textTheme.bodyMedium),
              const SizedBox(height: 18),
              if (menu.categories.isNotEmpty)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(children: menu.categories.map((categoryName) => Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(label: Text(categoryName), selected: categoryName == category, onSelected: (_) => onCategoryChanged(categoryName)),
                  )).toList()),
                ),
            ]),
          ),
        ),
        if (items.isEmpty)
          const SliverToBoxAdapter(child: Padding(padding: EdgeInsets.all(48), child: Center(child: Text('No items available right now.'))))
        else
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 110),
            sliver: SliverList.separated(
              itemCount: items.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (context, index) => _MenuItemCard(item: items[index], onAdd: onAdd),
            ),
          ),
      ],
    );
  }
}

class _MenuItemCard extends StatelessWidget {
  const _MenuItemCard({required this.item, required this.onAdd});
  final QRMenuItem item;
  final ValueChanged<QRMenuItem> onAdd;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: Colors.black.withValues(alpha: 0.06))),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(item.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w750)),
            if (item.description?.isNotEmpty == true) ...[
              const SizedBox(height: 5),
              Text(item.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: Theme.of(context).textTheme.bodySmall),
            ],
            const SizedBox(height: 10),
            Text('₹${item.price.toStringAsFixed(0)}', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800)),
          ])),
          const SizedBox(width: 12),
          OutlinedButton.icon(
            onPressed: item.available ? () => onAdd(item) : null,
            icon: Icon(item.available ? Icons.add : Icons.remove_circle_outline, size: 18),
            label: Text(item.available ? 'Add' : 'Unavailable'),
          ),
        ]),
      ),
    );
  }
}

class _CartSheet extends StatelessWidget {
  const _CartSheet({required this.state, required this.notifier, required this.nameController, required this.phoneController});
  final QROrderingState state;
  final QROrderingNotifier notifier;
  final TextEditingController nameController;
  final TextEditingController phoneController;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('Your order', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
          const SizedBox(height: 4),
          Text('Review before sending to the kitchen.'),
          const SizedBox(height: 16),
          Flexible(
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: state.cart.length,
              separatorBuilder: (_, _) => const Divider(height: 18),
              itemBuilder: (context, index) {
                final line = state.cart[index];
                return Row(children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(line.item.name, style: const TextStyle(fontWeight: FontWeight.w700)),
                    if (line.modifiers.isNotEmpty) Text(line.modifiers.map((modifier) => modifier.name).join(', '), style: Theme.of(context).textTheme.bodySmall),
                    Text('₹${line.total.toStringAsFixed(0)}', style: Theme.of(context).textTheme.bodyMedium),
                  ])),
                  IconButton(onPressed: () => notifier.updateQuantity(index, line.quantity - 1), icon: const Icon(Icons.remove_circle_outline)),
                  Text('${line.quantity}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  IconButton(onPressed: () => notifier.updateQuantity(index, line.quantity + 1), icon: const Icon(Icons.add_circle_outline)),
                ]);
              },
            ),
          ),
          const SizedBox(height: 10),
          TextField(controller: nameController, textCapitalization: TextCapitalization.words, decoration: const InputDecoration(labelText: 'Your name (optional)', prefixIcon: Icon(Icons.person_outline))),
          const SizedBox(height: 10),
          TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone (optional)', prefixIcon: Icon(Icons.phone_outlined))),
          const SizedBox(height: 16),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Total', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
            Text('₹${state.cartTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
          ]),
          if (state.error != null) ...[
            const SizedBox(height: 10),
            Text(state.error!, style: TextStyle(color: Theme.of(context).colorScheme.error)),
          ],
          const SizedBox(height: 14),
          SizedBox(width: double.infinity, child: FilledButton(
            onPressed: state.submitting || state.cart.isEmpty
                ? null
                : () async {
                    await notifier.submit(customerName: nameController.text, customerPhone: phoneController.text);
                    if (context.mounted && refMounted(context)) Navigator.of(context).pop();
                  },
            style: FilledButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
            child: state.submitting ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('Place order'),
          )),
        ]),
      ),
    );
  }
}

bool refMounted(BuildContext context) => context.mounted;

class _ConfirmationView extends StatelessWidget {
  const _ConfirmationView({required this.state, required this.onRefresh});
  final QROrderingState state;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final status = state.status?.status ?? state.confirmation!.status;
    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 520),
              child: Column(children: [
                const SizedBox(height: 36),
                Container(width: 76, height: 76, decoration: BoxDecoration(color: Colors.green.withValues(alpha: 0.12), shape: BoxShape.circle), child: const Icon(Icons.check_rounded, size: 44, color: Colors.green)),
                const SizedBox(height: 22),
                Text('Order received', style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('Order ${state.confirmation!.orderNumber} is now in the SpiceOS kitchen.', textAlign: TextAlign.center),
                const SizedBox(height: 28),
                Card(elevation: 0, child: Padding(padding: const EdgeInsets.all(20), child: Column(children: [
                  _StatusRow(label: 'Table', value: state.confirmation!.tableName),
                  const Divider(height: 24),
                  _StatusRow(label: 'Status', value: _statusLabel(status)),
                  const Divider(height: 24),
                  _StatusRow(label: 'Total', value: '₹${state.confirmation!.total.toStringAsFixed(0)}'),
                ]))),
                const SizedBox(height: 18),
                Text('We will keep this screen updated automatically.', style: Theme.of(context).textTheme.bodySmall, textAlign: TextAlign.center),
                const SizedBox(height: 18),
                OutlinedButton.icon(onPressed: onRefresh, icon: const Icon(Icons.refresh), label: const Text('Refresh status')),
              ]),
            ),
          ),
        ),
      ),
    );
  }

  static String _statusLabel(String status) {
    switch (status) {
      case 'preparing': return 'Being prepared';
      case 'ready': return 'Ready';
      case 'out_for_delivery': return 'On the way';
      case 'delivered': return 'Delivered';
      case 'cancelled': return 'Cancelled';
      default: return 'Order received';
    }
  }
}

class _StatusRow extends StatelessWidget {
  const _StatusRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) => Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
        Text(value, style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w700)),
      ]);
}

class _ErrorView extends StatelessWidget {
  const _ErrorView({required this.message, required this.onRetry});
  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) => Center(child: Padding(padding: const EdgeInsets.all(32), child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.restaurant_outlined, size: 52),
        const SizedBox(height: 16),
        Text('Menu unavailable', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Text(message, textAlign: TextAlign.center),
        const SizedBox(height: 18),
        FilledButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: const Text('Try again')),
      ])));
}
