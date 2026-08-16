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

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; _needsRestaurant = false; });
    try {
      final response = await ref.read(apiClientProvider).get('/qr/admin/restaurant');
      final restaurantId = response.data['restaurant_id'] as String;
      final items = await ref.read(menuRepositoryProvider).list(
        restaurantId: restaurantId,
        branchId: _branch.text.trim(),
      );
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

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() { _branch.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Menu Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              SizedBox(height: 6),
              Text('Manage your live menu by branch, category and availability.'),
            ])),
            SizedBox(width: 220, child: TextField(controller: _branch, decoration: const InputDecoration(labelText: 'Branch ID'))),
            const SizedBox(width: 12),
            FilledButton.icon(onPressed: _load, icon: const Icon(Icons.refresh), label: const Text('Refresh')),
          ]),
          const SizedBox(height: 24),
          if (_error != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline, color: AppColors.error),
                    const SizedBox(width: 12),
                    Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error))),
                    if (_needsRestaurant)
                      FilledButton.icon(
                        onPressed: () => context.go('/settings'),
                        icon: const Icon(Icons.storefront_outlined),
                        label: const Text('Set Up Restaurant'),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          Expanded(child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Card(child: _items.isEmpty
                  ? const Center(child: Text('No menu items yet. Add your first item from Restaurant Setup.'))
                  : ListView.separated(
                      padding: const EdgeInsets.all(8),
                      itemCount: _items.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (_, index) {
                        final item = _items[index];
                        return ListTile(
                          leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: .1), child: const Icon(Icons.restaurant_menu, color: AppColors.primary)),
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('${item.category}${item.description == null || item.description!.isEmpty ? '' : ' • ${item.description}'}'),
                          trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('₹${item.price.toStringAsFixed(2)}', style: const TextStyle(fontWeight: FontWeight.w700)),
                            Text(item.available ? 'Available' : 'Unavailable', style: TextStyle(color: item.available ? AppColors.success : AppColors.error, fontSize: 12)),
                          ]),
                        );
                      },
                    ))),
        ],
      ),
    );
  }
}
