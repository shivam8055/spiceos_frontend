import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';

class QRCustomerOrderScreen extends ConsumerStatefulWidget {
  const QRCustomerOrderScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<QRCustomerOrderScreen> createState() => _QRCustomerOrderScreenState();
}

class _QRCustomerOrderScreenState extends ConsumerState<QRCustomerOrderScreen> {
  Map<String, dynamic>? _context;
  List<_CustomerMenuItem> _items = const [];
  final Map<int, int> _cart = {};
  bool _loading = true;
  bool _placingOrder = false;
  String? _error;
  String? _orderNumber;
  String? _publicOrderToken;
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    _loadMenu();
  }

  Future<void> _loadMenu() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final response = await ref.read(apiClientProvider).get('/qr/public/qr/${widget.token}/menu');
      final data = Map<String, dynamic>.from(response.data as Map);
      final items = (data['items'] as List? ?? const [])
          .map((item) => _CustomerMenuItem.fromJson(Map<String, dynamic>.from(item as Map)))
          .toList();

      if (!mounted) return;
      setState(() {
        _context = Map<String, dynamic>.from(data['context'] as Map? ?? const {});
        _items = items;
        _loading = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _dioMessage(e);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to load this menu. Please scan the table QR again.';
      });
    }
  }

  String _dioMessage(DioException e) {
    final data = e.response?.data;
    if (data is Map && data['detail'] != null) return data['detail'].toString();
    return 'Unable to load this menu right now.';
  }

  List<_CustomerMenuItem> get _visibleItems {
    if (_selectedCategory == 'All') return _items;
    return _items.where((item) => item.category == _selectedCategory).toList();
  }

  List<String> get _categories {
    final values = _items.map((item) => item.category).where((value) => value.isNotEmpty).toSet().toList();
    return ['All', ...values];
  }

  int get _cartCount => _cart.values.fold(0, (sum, value) => sum + value);

  double get _cartTotal => _items.fold(0, (sum, item) => sum + item.price * (_cart[item.id] ?? 0));

  void _changeQuantity(_CustomerMenuItem item, int delta) {
    final next = (_cart[item.id] ?? 0) + delta;
    setState(() {
      if (next <= 0) {
        _cart.remove(item.id);
      } else {
        _cart[item.id] = next;
      }
    });
  }

  Future<void> _openCart() async {
    if (_cart.isEmpty) return;

    final nameController = TextEditingController();
    final phoneController = TextEditingController();

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            final cartItems = _items.where((item) => _cart.containsKey(item.id)).toList();
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 18,
                bottom: MediaQuery.of(context).viewInsets.bottom + 20,
              ),
              child: SafeArea(
                top: false,
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          const Expanded(
                            child: Text('Your order', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
                          ),
                          IconButton(onPressed: () => Navigator.pop(sheetContext), icon: const Icon(Icons.close)),
                        ],
                      ),
                      if (_context?['table_name'] != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: Text('Table ${_context!['table_name']}', style: TextStyle(color: Colors.grey.shade700)),
                        ),
                      ...cartItems.map(
                        (item) => ListTile(
                          contentPadding: EdgeInsets.zero,
                          title: Text(item.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                          subtitle: Text('₹${item.price.toStringAsFixed(0)} each'),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(onPressed: () { _changeQuantity(item, -1); setSheetState(() {}); }, icon: const Icon(Icons.remove_circle_outline)),
                              Text('${_cart[item.id] ?? 0}', style: const TextStyle(fontWeight: FontWeight.w700)),
                              IconButton(onPressed: () { _changeQuantity(item, 1); setSheetState(() {}); }, icon: const Icon(Icons.add_circle_outline)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: nameController,
                        textInputAction: TextInputAction.next,
                        decoration: const InputDecoration(labelText: 'Name (optional)', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration: const InputDecoration(labelText: 'Phone (optional)', border: OutlineInputBorder()),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const Expanded(child: Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700))),
                          Text('₹${_cartTotal.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                        ],
                      ),
                      const SizedBox(height: 14),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: _placingOrder || _cart.isEmpty
                              ? null
                              : () async {
                                  await _placeOrder(
                                    nameController.text.trim().isEmpty ? null : nameController.text.trim(),
                                    phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                                  );
                                  if (mounted && _orderNumber != null) Navigator.pop(sheetContext);
                                },
                          icon: const Icon(Icons.receipt_long),
                          label: Text(_placingOrder ? 'Placing order…' : 'Place order · ₹${_cartTotal.toStringAsFixed(0)}'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    nameController.dispose();
    phoneController.dispose();
  }

  Future<void> _placeOrder(String? name, String? phone) async {
    setState(() => _placingOrder = true);

    final items = _cart.entries
        .map((entry) => {
              'menu_item_id': entry.key,
              'quantity': entry.value,
              'modifier_ids': <String>[],
            })
        .toList();

    try {
      final response = await ref.read(apiClientProvider).postWithHeaders(
        '/qr/public/qr/${widget.token}/orders',
        {
          'items': items,
          'customer_name': name,
          'customer_phone': phone,
        },
        headers: {
          'Idempotency-Key': 'qr-${DateTime.now().microsecondsSinceEpoch}',
        },
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      if (!mounted) return;
      setState(() {
        _orderNumber = data['order_number']?.toString();
        _publicOrderToken = data['public_order_token']?.toString();
        _cart.clear();
        _placingOrder = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      setState(() => _placingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_dioMessage(e))));
    } catch (_) {
      if (!mounted) return;
      setState(() => _placingOrder = false);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Could not place the order. Please try again.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_orderNumber != null) return _buildSuccess();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_context?['restaurant_name']?.toString() ?? 'SpiceOS', style: const TextStyle(fontWeight: FontWeight.w800)),
            if (_context?['table_name'] != null)
              Text('Table ${_context!['table_name']}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
          ],
        ),
        actions: [
          IconButton(onPressed: _loadMenu, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? _buildError()
              : RefreshIndicator(
                  onRefresh: _loadMenu,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 110),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDE4),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Order from your table', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
                            SizedBox(height: 5),
                            Text('Browse the menu, add your favourites and place your order directly.'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 8),
                          itemBuilder: (_, index) {
                            final category = _categories[index];
                            final selected = category == _selectedCategory;
                            return ChoiceChip(
                              label: Text(category),
                              selected: selected,
                              onSelected: (_) => setState(() => _selectedCategory = category),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 16),
                      ..._visibleItems.map(_buildMenuItem),
                      if (_visibleItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: Text('No items are currently available.')),
                        ),
                    ],
                  ),
                ),
      bottomNavigationBar: _cartCount == 0 || _error != null
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: ElevatedButton(
                  onPressed: _openCart,
                  style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 16)),
                  child: Row(
                    children: [
                      CircleAvatar(radius: 12, child: Text('$_cartCount', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800))),
                      const SizedBox(width: 10),
                      const Expanded(child: Text('View order', style: TextStyle(fontWeight: FontWeight.w700))),
                      Text('₹${_cartTotal.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800)),
                    ],
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildMenuItem(_CustomerMenuItem item) {
    final quantity = _cart[item.id] ?? 0;
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item.category.toUpperCase(), style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w700, letterSpacing: 0.8)),
                  const SizedBox(height: 4),
                  Text(item.name, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w750)),
                  if (item.description != null && item.description!.isNotEmpty) ...[
                    const SizedBox(height: 5),
                    Text(item.description!, maxLines: 2, overflow: TextOverflow.ellipsis, style: TextStyle(color: Colors.grey.shade700, height: 1.3)),
                  ],
                  const SizedBox(height: 9),
                  Text('₹${item.price.toStringAsFixed(0)}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
                ],
              ),
            ),
            const SizedBox(width: 12),
            quantity == 0
                ? OutlinedButton(onPressed: item.available ? () => _changeQuantity(item, 1) : null, child: const Text('Add'))
                : Container(
                    decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade300), borderRadius: BorderRadius.circular(12)),
                    child: Row(
                      children: [
                        IconButton(onPressed: () => _changeQuantity(item, -1), icon: const Icon(Icons.remove, size: 18)),
                        Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w800)),
                        IconButton(onPressed: () => _changeQuantity(item, 1), icon: const Icon(Icons.add, size: 18)),
                      ],
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _buildError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.qr_code_2, size: 58),
            const SizedBox(height: 16),
            Text(_error!, textAlign: TextAlign.center, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
            const SizedBox(height: 18),
            ElevatedButton.icon(onPressed: _loadMenu, icon: const Icon(Icons.refresh), label: const Text('Try again')),
          ],
        ),
      ),
    );
  }

  Widget _buildSuccess() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 0,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircleAvatar(radius: 34, child: Icon(Icons.check, size: 36)),
                    const SizedBox(height: 18),
                    const Text('Order placed!', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)),
                    const SizedBox(height: 8),
                    Text('Order $_orderNumber', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 6),
                    Text('Your order has been sent to the kitchen. Table ${_context?['table_name'] ?? ''}.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade700, height: 1.4)),
                    const SizedBox(height: 22),
                    if (_publicOrderToken != null)
                      Text('Keep this page open to track your order.', textAlign: TextAlign.center, style: TextStyle(color: Colors.grey.shade600)),
                    const SizedBox(height: 18),
                    OutlinedButton.icon(
                      onPressed: () => setState(() => _orderNumber = null),
                      icon: const Icon(Icons.add_shopping_cart),
                      label: const Text('Order something else'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomerMenuItem {
  const _CustomerMenuItem({
    required this.id,
    required this.category,
    required this.name,
    required this.description,
    required this.price,
    required this.available,
  });

  final int id;
  final String category;
  final String name;
  final String? description;
  final double price;
  final bool available;

  factory _CustomerMenuItem.fromJson(Map<String, dynamic> json) {
    return _CustomerMenuItem(
      id: (json['id'] as num).toInt(),
      category: json['category']?.toString() ?? 'Menu',
      name: json['name']?.toString() ?? 'Item',
      description: json['description']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      available: json['available'] == true,
    );
  }
}
