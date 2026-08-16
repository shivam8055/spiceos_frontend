import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_shell.dart';
import '../models/restaurant.dart';
import '../repositories/restaurant_repository.dart';

final restaurantRepositoryProvider = Provider<RestaurantRepository>(
  (ref) => RestaurantRepository(ref.read(apiClientProvider)),
);

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});
  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  Restaurant? _restaurant;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadRestaurant();
  }

  Future<void> _loadRestaurant() async {
    setState(() => _loading = true);
    final restaurant = await ref.read(restaurantRepositoryProvider).getCurrent();
    if (!mounted) return;
    setState(() {
      _restaurant = restaurant;
      _loading = false;
    });
  }

  Future<void> _createRestaurant() async {
    final draft = await showDialog<_RestaurantDraft>(
      context: context,
      builder: (_) => const _CreateRestaurantDialog(),
    );
    if (draft == null) return;
    setState(() => _loading = true);
    try {
      final restaurant = await ref.read(restaurantRepositoryProvider).create(
        name: draft.name,
        logoUrl: draft.logoUrl,
      );
      if (!mounted) return;
      setState(() {
        _restaurant = restaurant;
        _loading = false;
      });
      _message('Restaurant created successfully.');
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _message(e.response?.data?['detail']?.toString() ?? 'Unable to create restaurant.');
    }
  }

  Future<void> _addMenuItem() async {
    final restaurant = _restaurant;
    if (restaurant == null) return;
    final draft = await showDialog<_MenuDraft>(
      context: context,
      builder: (_) => const _AddMenuItemDialog(),
    );
    if (draft == null) return;
    try {
      await ref.read(restaurantRepositoryProvider).createMenuItem(
        restaurantId: restaurant.restaurantId,
        branchId: draft.branchId,
        category: draft.category,
        name: draft.name,
        description: draft.description,
        price: draft.price,
      );
      if (mounted) _message('${draft.name} added to the live menu.');
    } on DioException catch (e) {
      if (mounted) _message(e.response?.data?['detail']?.toString() ?? 'Unable to add menu item.');
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _loadRestaurant,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Restaurant Setup', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                            SizedBox(height: 6),
                            Text('Manage restaurant identity and the live menu used by QR ordering.'),
                          ],
                        ),
                      ),
                      if (_restaurant == null)
                        FilledButton.icon(
                          onPressed: _createRestaurant,
                          icon: const Icon(Icons.add_business_outlined),
                          label: const Text('Create Restaurant'),
                        ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_restaurant == null) const _EmptyRestaurantCard(),
                  if (_restaurant != null) ...[
                    _RestaurantCard(restaurant: _restaurant!),
                    const SizedBox(height: 20),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('Live Menu', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                                      SizedBox(height: 4),
                                      Text('Create restaurant-owned menu items. Server remains authoritative for tenant and price.'),
                                    ],
                                  ),
                                ),
                                FilledButton.icon(
                                  onPressed: _addMenuItem,
                                  icon: const Icon(Icons.add),
                                  label: const Text('Add Item'),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: AppColors.surface,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: AppColors.border),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.restaurant_menu_outlined, color: AppColors.primary),
                                  SizedBox(width: 12),
                                  Expanded(child: Text('Menu item creation is live. Listing, categories, modifiers, availability and QR table management are next slices.')),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
    );
  }
}

class _RestaurantCard extends StatelessWidget {
  const _RestaurantCard({required this.restaurant});
  final Restaurant restaurant;
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              CircleAvatar(
                radius: 30,
                backgroundColor: AppColors.primary.withValues(alpha: .1),
                child: const Icon(Icons.storefront_outlined, color: AppColors.primary, size: 30),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(restaurant.name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 5),
                    Text('Restaurant ID: ${restaurant.restaurantId}', style: const TextStyle(color: AppColors.textSecondary)),
                  ],
                ),
              ),
              Chip(
                avatar: Icon(Icons.check_circle, size: 16, color: restaurant.active ? AppColors.success : AppColors.error),
                label: Text(restaurant.active ? 'Active' : 'Inactive'),
              ),
            ],
          ),
        ),
      );
}

class _EmptyRestaurantCard extends StatelessWidget {
  const _EmptyRestaurantCard();
  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: Column(
            children: [
              const Icon(Icons.store_mall_directory_outlined, size: 56, color: AppColors.primary),
              const SizedBox(height: 16),
              const Text('No restaurant connected', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('Create your restaurant first. Spice Box is no longer treated as the global restaurant.', textAlign: TextAlign.center),
            ],
          ),
        ),
      );
}

class _RestaurantDraft {
  const _RestaurantDraft(this.name, this.logoUrl);
  final String name;
  final String? logoUrl;
}

class _CreateRestaurantDialog extends StatefulWidget {
  const _CreateRestaurantDialog();
  @override
  State<_CreateRestaurantDialog> createState() => _CreateRestaurantDialogState();
}

class _CreateRestaurantDialogState extends State<_CreateRestaurantDialog> {
  final _name = TextEditingController();
  final _logo = TextEditingController();
  @override
  void dispose() {
    _name.dispose();
    _logo.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Create Restaurant'),
        content: SizedBox(
          width: 440,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: _name, autofocus: true, decoration: const InputDecoration(labelText: 'Restaurant name', hintText: 'Spice Box Cloud Kitchen')),
              const SizedBox(height: 14),
              TextField(controller: _logo, decoration: const InputDecoration(labelText: 'Logo URL (optional)')),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              if (_name.text.trim().isEmpty) return;
              Navigator.pop(context, _RestaurantDraft(_name.text.trim(), _logo.text.trim().isEmpty ? null : _logo.text.trim()));
            },
            child: const Text('Create'),
          ),
        ],
      );
}

class _MenuDraft {
  const _MenuDraft({required this.name, required this.category, required this.branchId, required this.description, required this.price});
  final String name;
  final String category;
  final String branchId;
  final String description;
  final double price;
}

class _AddMenuItemDialog extends StatefulWidget {
  const _AddMenuItemDialog();
  @override
  State<_AddMenuItemDialog> createState() => _AddMenuItemDialogState();
}

class _AddMenuItemDialogState extends State<_AddMenuItemDialog> {
  final _name = TextEditingController();
  final _category = TextEditingController(text: 'Main Course');
  final _branch = TextEditingController(text: 'main');
  final _description = TextEditingController();
  final _price = TextEditingController();
  @override
  void dispose() {
    for (final c in [_name, _category, _branch, _description, _price]) c.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) => AlertDialog(
        title: const Text('Add Menu Item'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(controller: _name, autofocus: true, decoration: const InputDecoration(labelText: 'Item name')),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: TextField(controller: _category, decoration: const InputDecoration(labelText: 'Category'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _branch, decoration: const InputDecoration(labelText: 'Branch ID'))),
                ]),
                const SizedBox(height: 12),
                TextField(controller: _price, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: const InputDecoration(labelText: 'Price (₹)')),
                const SizedBox(height: 12),
                TextField(controller: _description, maxLines: 3, decoration: const InputDecoration(labelText: 'Description')),
              ],
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final price = double.tryParse(_price.text.trim());
              if (_name.text.trim().isEmpty || _category.text.trim().isEmpty || _branch.text.trim().isEmpty || price == null || price < 0) return;
              Navigator.pop(context, _MenuDraft(name: _name.text.trim(), category: _category.text.trim(), branchId: _branch.text.trim(), description: _description.text.trim(), price: price));
            },
            child: const Text('Add to Menu'),
          ),
        ],
      );
}
