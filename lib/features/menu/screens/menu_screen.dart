import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_shell.dart';
import '../models/menu_item.dart';
import '../repositories/menu_repository.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) => MenuRepository(ref.read(apiClientProvider)));

class MenuScreen extends ConsumerStatefulWidget {
  const MenuScreen({super.key});
  @override
  ConsumerState<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends ConsumerState<MenuScreen> {
  final _branch = TextEditingController(text: 'main');
  bool _loading = false;
  String? _error;
  List<MenuItem> _items = const [];
  bool _needsRestaurant = false;
  final Set<int> _saving = {};

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; _needsRestaurant = false; });
    try {
      final response = await ref.read(apiClientProvider).get('/qr/admin/restaurant');
      final restaurantId = response.data['restaurant_id'] as String;
      final items = await ref.read(menuRepositoryProvider).list(restaurantId: restaurantId, branchId: _branch.text.trim());
      if (!mounted) return;
      setState(() { _items = items; _loading = false; });
    } on DioException catch (e) {
      if (!mounted) return;
      final status = e.response?.statusCode;
      final detail = e.response?.data is Map ? e.response?.data['detail']?.toString() : null;
      setState(() {
        _loading = false;
        _needsRestaurant = status == 409 || (detail?.toLowerCase().contains('not associated with a restaurant') ?? false);
        _error = detail ?? 'Unable to load the restaurant menu.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() { _loading = false; _error = e.toString(); });
    }
  }

  Future<void> _saveItem(MenuItem item) async {
    if (_saving.contains(item.id)) return;
    setState(() => _saving.add(item.id));
    try {
      final updated = await ref.read(menuRepositoryProvider).update(
        itemId: item.id,
        category: item.category,
        name: item.name,
        description: item.description,
        price: item.price,
        available: item.available,
      );
      if (!mounted) return;
      setState(() {
        _items = _items.map((value) => value.id == updated.id ? updated : value).toList();
        _saving.remove(item.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu item updated.')));
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _saving.remove(item.id));
      final detail = e.response?.data is Map ? e.response?.data['detail']?.toString() : null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(detail ?? 'Unable to update menu item.')));
    }
  }

  Future<void> _editItem(MenuItem item) async {
    final category = TextEditingController(text: item.category);
    final name = TextEditingController(text: item.name);
    final description = TextEditingController(text: item.description ?? '');
    final price = TextEditingController(text: item.price.toStringAsFixed(2));
    bool available = item.available;

    final values = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Edit menu item'),
          content: SingleChildScrollView(
            child: SizedBox(
              width: 420,
              child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(controller: category, decoration: const InputDecoration(labelText: 'Category')),
                const SizedBox(height: 12),
                TextField(controller: name, decoration: const InputDecoration(labelText: 'Food item name')),
                const SizedBox(height: 12),
                TextField(controller: description, maxLines: 2, decoration: const InputDecoration(labelText: 'Description (optional)')),
                const SizedBox(height: 12),
                TextField(controller: price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Price (₹)')),
                const SizedBox(height: 8),
                SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Available for ordering'), value: available, onChanged: (value) => setDialogState(() => available = value)),
              ]),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Cancel')),
            FilledButton(onPressed: () {
              final parsed = double.tryParse(price.text.trim());
              if (category.text.trim().isEmpty || name.text.trim().isEmpty || parsed == null || parsed < 0) return;
              Navigator.pop(dialogContext, {
                'category': category.text.trim(),
                'name': name.text.trim(),
                'description': description.text.trim().isEmpty ? null : description.text.trim(),
                'price': parsed,
                'available': available,
              });
            }, child: const Text('Save')),
          ],
        ),
      ),
    );
    category.dispose();
    name.dispose();
    description.dispose();
    price.dispose();
    if (values == null || !mounted) return;

    final edited = MenuItem(
      id: item.id,
      restaurantId: item.restaurantId,
      branchId: item.branchId,
      category: values['category'] as String,
      name: values['name'] as String,
      description: values['description'] as String?,
      price: values['price'] as double,
      available: values['available'] as bool,
      modifiers: item.modifiers,
    );
    await _saveItem(edited);
  }

  Future<void> _toggleAvailability(MenuItem item) async {
    final updated = MenuItem(
      id: item.id,
      restaurantId: item.restaurantId,
      branchId: item.branchId,
      category: item.category,
      name: item.name,
      description: item.description,
      price: item.price,
      available: !item.available,
      modifiers: item.modifiers,
    );
    await _saveItem(updated);
  }

  Future<void> _deleteItem(MenuItem item) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Delete menu item?'),
        content: Text('Remove “${item.name}” from this branch menu? This cannot be undone.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton.tonal(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true || !mounted || _saving.contains(item.id)) return;
    setState(() => _saving.add(item.id));
    try {
      await ref.read(menuRepositoryProvider).delete(itemId: item.id);
      if (!mounted) return;
      setState(() {
        _items = _items.where((entry) => entry.id != item.id).toList();
        _saving.remove(item.id);
      });
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu item deleted.')));
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _saving.remove(item.id));
      final detail = e.response?.data is Map ? e.response?.data['detail']?.toString() : null;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(detail ?? 'Unable to delete menu item.')));
    }
  }

  Map<String, List<MenuItem>> get _groupedItems {
    final grouped = <String, List<MenuItem>>{};
    for (final item in _items) {
      final category = item.category.trim().isEmpty ? 'Other' : item.category.trim();
      grouped.putIfAbsent(category, () => []).add(item);
    }
    return grouped;
  }

  @override
  void initState() { super.initState(); _load(); }
  @override
  void dispose() { _branch.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final groups = _groupedItems;
    return AppShell(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('Menu Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
            SizedBox(height: 6),
            Text('Organize your menu by category, edit food items, prices and availability, or remove items.'),
          ])),
          OutlinedButton.icon(onPressed: () => context.push('/menu/import'), icon: const Icon(Icons.auto_awesome), label: const Text('Import with AI')),
          const SizedBox(width: 12),
          SizedBox(width: 180, child: TextField(controller: _branch, decoration: const InputDecoration(labelText: 'Branch ID'))),
          const SizedBox(width: 12),
          FilledButton.icon(onPressed: _loading ? null : _load, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
        ]),
        const SizedBox(height: 24),
        if (_error != null)
          Card(child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
            const Icon(Icons.info_outline, color: AppColors.error), const SizedBox(width: 12),
            Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error))),
            if (_needsRestaurant) FilledButton.icon(onPressed: () => context.go('/settings'), icon: const Icon(Icons.storefront_outlined), label: const Text('Set Up Restaurant')),
          ]))),
        const SizedBox(height: 12),
        Expanded(child: _loading
            ? const Center(child: CircularProgressIndicator())
            : Card(child: _items.isEmpty
                ? const Center(child: Text('No menu items yet. Import your existing menu or add your first item.'))
                : ListView(
                    padding: const EdgeInsets.all(12),
                    children: groups.entries.map((entry) {
                      final category = entry.key;
                      final categoryItems = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 14),
                        elevation: 0,
                        color: Theme.of(context).colorScheme.surfaceContainerLowest,
                        child: ExpansionTile(
                          initiallyExpanded: true,
                          leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: .1), child: const Icon(Icons.restaurant_menu, color: AppColors.primary)),
                          title: Text(category, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
                          subtitle: Text('${categoryItems.length} ${categoryItems.length == 1 ? 'item' : 'items'}'),
                          children: categoryItems.map((item) {
                            final saving = _saving.contains(item.id);
                            return Column(children: [
                              const Divider(height: 1),
                              ListTile(
                                contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                                title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: item.description == null || item.description!.isEmpty ? null : Text(item.description!),
                                trailing: Wrap(spacing: 2, crossAxisAlignment: WrapCrossAlignment.center, children: [
                                  Text('₹${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                  IconButton(tooltip: 'Edit item', onPressed: saving ? null : () => _editItem(item), icon: const Icon(Icons.edit_outlined)),
                                  IconButton(tooltip: 'Delete item', onPressed: saving ? null : () => _deleteItem(item), icon: const Icon(Icons.delete_outline)),
                                  Switch(value: item.available, onChanged: saving ? null : (_) => _toggleAvailability(item)),
                                ]),
                              ),
                            ]);
                          }).toList(),
                        ),
                      );
                    }).toList(),
                  )),
      ],),
    );
  }
}
