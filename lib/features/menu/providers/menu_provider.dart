import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../models/menu_category.dart';
import '../models/menu_item.dart';
import '../repositories/menu_repository.dart';

final menuRepositoryProvider = Provider<MenuRepository>((ref) => MenuRepository(ref.read(apiClientProvider)));

class MenuState {
  const MenuState({this.loading = true, this.items = const [], this.error});
  final bool loading;
  final List<MenuItem> items;
  final String? error;

  List<MenuCategory> get categories {
    final counts = <String, int>{};
    for (final item in items) {
      counts[item.category] = (counts[item.category] ?? 0) + 1;
    }
    return counts.entries.map((entry) => MenuCategory(name: entry.key, itemCount: entry.value)).toList()
      ..sort((a, b) => a.name.compareTo(b.name));
  }
}

class MenuNotifier extends StateNotifier<MenuState> {
  MenuNotifier(this._repository) : super(const MenuState());
  final MenuRepository _repository;

  Future<void> load({required String restaurantId, required String branchId}) async {
    state = const MenuState(loading: true);
    try {
      state = MenuState(loading: false, items: await _repository.list(restaurantId: restaurantId, branchId: branchId));
    } catch (e) {
      state = MenuState(loading: false, error: e.toString());
    }
  }
}

final menuProvider = StateNotifierProvider<MenuNotifier, MenuState>((ref) => MenuNotifier(ref.read(menuRepositoryProvider)));
