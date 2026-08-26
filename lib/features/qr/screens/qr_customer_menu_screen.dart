import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../services/payment_checkout.dart';

class QRCustomerMenuScreen extends ConsumerStatefulWidget {
  const QRCustomerMenuScreen({super.key, required this.token});
  final String token;
  @override ConsumerState<QRCustomerMenuScreen> createState() => _QRCustomerMenuScreenState();
}

class _QRCustomerMenuScreenState extends ConsumerState<QRCustomerMenuScreen> {
  Map<String, dynamic> _context = const {};
  List<_Item> _items = const [];
  final Map<int, int> _cart = {};
  String _category = 'All', _foodFilter = 'All';
  bool _loading = true, _placing = false, _paying = false;
  String? _error, _orderNumber, _orderToken, _orderStatus, _paymentStatus;
  Timer? _timer;
  @override void initState() { super.initState(); _load(); }
  @override void dispose() { _timer?.cancel(); super.dispose(); }
  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final response = await ref.read(apiClientProvider).get('/qr/public/qr/${widget.token}/menu');
      final data = Map<String, dynamic>.from(response.data as Map);
      final items = (data['items'] as List? ?? const []).map((e) => _Item.fromJson(Map<String, dynamic>.from(e as Map))).toList();
      if (!mounted) return;
      setState(() { _context = Map<String, dynamic>.from(data['context'] as Map? ?? const {}); _items = items; _loading = false; });
    } on DioException catch (e) { if (mounted) setState(() { _loading = false; _error = _message(e); }); }
    catch (_) { if (mounted) setState(() { _loading = false; _error = 'Unable to load this menu. Please scan the table QR again.'; }); }
  }
  String _message(DioException e) => e.response?.data is Map && e.response?.data['detail'] != null ? e.response!.data['detail'].toString() : 'Something went wrong. Please try again.';
  List<_Item> get _visible => _items.where((item) => (_category == 'All' || item.category == _category) && (_foodFilter == 'All' || item.foodType == _foodFilter)).toList();
  List<String> get _categories => ['All', ..._items.map((e) => e.category).where((e) => e.isNotEmpty).toSet()];
  Map<String, List<_Item>> get _groups { final r = <String, List<_Item>>{}; for (final i in _visible) r.putIfAbsent(i.displayGroup, () => []).add(i); return r; }
  int get _cartCount => _cart.values.fold(0, (a, b) => a + b);
  double get _total => _items.fold(0, (a, i) => a + i.price * (_cart[i.id] ?? 0));
  void _qty(_Item i, int d) { final n = (_cart[i.id] ?? 0) + d; setState(() { if (n <= 0) _cart.remove(i.id); else _cart[i.id] = n; }); }
  Future<void> _openCart() async {
    if (_cart.isEmpty) return;
    final name = TextEditingController(), phone = TextEditingController();
    await showModalBottomSheet<void>(context: context, isScrollControlled: true, backgroundColor: Colors.white, builder: (sheet) => StatefulBuilder(builder: (context, setSheet) {
      final selected = _items.where((e) => _cart.containsKey(e.id)).toList();
      return Padding(padding: EdgeInsets.fromLTRB(18, 18, 18, MediaQuery.of(context).viewInsets.bottom + 18), child: SafeArea(top: false, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        Row(children: [const Expanded(child: Text('Your order', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))), IconButton(onPressed: () => Navigator.pop(sheet), icon: const Icon(Icons.close))]),
        ...selected.map((i) => ListTile(contentPadding: EdgeInsets.zero, leading: Text(i.symbol, style: const TextStyle(fontSize: 20)), title: Text(i.name, style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text('₹${i.price.toStringAsFixed(0)} each'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [IconButton(onPressed: () { _qty(i, -1); setSheet(() {}); }, icon: const Icon(Icons.remove_circle_outline)), Text('${_cart[i.id] ?? 0}', style: const TextStyle(fontWeight: FontWeight.w700)), IconButton(onPressed: () { _qty(i, 1); setSheet(() {}); }, icon: const Icon(Icons.add_circle_outline))])),
        const SizedBox(height: 8), TextField(controller: name, decoration: const InputDecoration(labelText: 'Name (optional)', border: OutlineInputBorder())), const SizedBox(height: 10), TextField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone (optional)', border: OutlineInputBorder())), const SizedBox(height: 14),
        Row(children: [const Expanded(child: Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))), Text('₹${_total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800))]), const SizedBox(height: 14),
        SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _placing ? null : () async { await _place(name.text.trim().isEmpty ? null : name.text.trim(), phone.text.trim().isEmpty ? null : phone.text.trim()); if (mounted && _orderNumber != null) Navigator.pop(sheet); }, icon: const Icon(Icons.receipt_long), label: Text(_placing ? 'Placing order…' : 'Place order · ₹${_total.toStringAsFixed(0)}'))),
      ]))));
    }));
    name.dispose(); phone.dispose();
  }
  Future<void> _place(String? name, String? phone) async {
    setState(() => _placing = true);
    try {
      final response = await ref.read(apiClientProvider).postWithHeaders('/qr/public/qr/${widget.token}/orders', {'items': _cart.entries.map((e) => {'menu_item_id': e.key, 'quantity': e.value, 'modifier_ids': <String>[]}).toList(), 'customer_name': name, 'customer_phone': phone}, headers: {'Idempotency-Key': 'qr-${DateTime.now().microsecondsSinceEpoch}'});
      final data = Map<String, dynamic>.from(response.data as Map);
      if (!mounted) return;
      setState(() { _orderNumber = data['order_number']?.toString(); _orderToken = data['public_order_token']?.toString(); _orderStatus = data['status']?.toString() ?? 'created'; _paymentStatus = 'pending'; _cart.clear(); _placing = false; });
      _poll();
    } on DioException catch (e) { if (mounted) { setState(() => _placing = false); ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(_message(e)))); } }
  }
  void _poll() { _timer?.cancel(); _loadStatus(); _timer = Timer.periodic(const Duration(seconds: 5), (_) => _loadStatus()); }
  Future<void> _loadStatus() async { if (_orderToken == null) return; try { final r = await ref.read(apiClientProvider).get('/qr/public/orders/$_orderToken'); final d = Map<String, dynamic>.from(r.data as Map); if (!mounted) return; setState(() { _orderStatus = d['status']?.toString() ?? _orderStatus; _paymentStatus = d['payment_status']?.toString() ?? _paymentStatus; }); if (_orderStatus == 'delivered' || _orderStatus == 'cancelled') _timer?.cancel(); } catch (_) {} }
  Future<void> _pay() async {
    if (_orderToken == null || _paying) return; setState(() => _paying = true);
    try { final r = await ref.read(apiClientProvider).post('/qr/public/orders/$_orderToken/payment'); final p = Map<String, dynamic>.from(r.data as Map); final result = await PaymentCheckout().open(keyId: p['key_id'].toString(), amount: p['amount_paise'].toString(), currency: p['currency'].toString(), orderId: p['provider_order_id'].toString(), name: _context['restaurant_name']?.toString() ?? 'SpiceOS'); if (result == null) return; await ref.read(apiClientProvider).post('/qr/public/orders/$_orderToken/payment/verify', {'provider_order_id': result['razorpay_order_id'], 'provider_payment_id': result['razorpay_payment_id'], 'signature': result['razorpay_signature']}); await _loadStatus(); } catch (e) { if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceFirst('Bad state: ', '')))); } finally { if (mounted) setState(() => _paying = false); }
  }
  String _statusText() => switch (_orderStatus) { 'preparing' => 'Preparing', 'ready' => 'Ready', 'outForDelivery' => 'On the way', 'delivered' => 'Delivered', 'cancelled' => 'Cancelled', _ => 'Order received' };
  @override Widget build(BuildContext context) {
    if (_orderNumber != null) return _success();
    return Scaffold(backgroundColor: const Color(0xFFF8F7F5), appBar: AppBar(backgroundColor: Colors.white, elevation: 0, title: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(_context['restaurant_name']?.toString() ?? 'SpiceOS', style: const TextStyle(fontWeight: FontWeight.w800)), if (_context['table_name'] != null) Text('Table ${_context['table_name']}', style: const TextStyle(fontSize: 12))]), actions: [IconButton(onPressed: _load, icon: const Icon(Icons.refresh))]),
      body: _loading ? const Center(child: CircularProgressIndicator()) : _error != null ? Center(child: Padding(padding: const EdgeInsets.all(24), child: Text(_error!))) : RefreshIndicator(onRefresh: _load, child: ListView(padding: const EdgeInsets.fromLTRB(14, 14, 14, 100), children: [
        Container(padding: const EdgeInsets.all(18), decoration: BoxDecoration(color: const Color(0xFFFFEDE4), borderRadius: BorderRadius.circular(18)), child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Order from your table', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800)), SizedBox(height: 5), Text('Choose a category or filter Veg / Non-Veg, then add items to your cart.')])),
        const SizedBox(height: 12), SizedBox(height: 44, child: ListView(scrollDirection: Axis.horizontal, children: [_foodChip('All', 'All'), _foodChip('🟢 Veg', 'VEG'), _foodChip('🔴 Non-Veg', 'NON-VEG')])), const SizedBox(height: 8),
        SizedBox(height: 42, child: ListView.separated(scrollDirection: Axis.horizontal, itemCount: _categories.length, separatorBuilder: (_, __) => const SizedBox(width: 7), itemBuilder: (_, i) { final c = _categories[i]; return ChoiceChip(label: Text(c.replaceAll(' / ', ' • ')), selected: _category == c, onSelected: (_) => setState(() => _category = c)); })), const SizedBox(height: 14),
        ..._groups.entries.map((e) => Card(margin: const EdgeInsets.only(bottom: 12), elevation: 0, child: ExpansionTile(initiallyExpanded: true, title: Text(e.key.replaceAll(' / ', ' • '), style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('${e.value.length} items'), children: e.value.map(_itemTile).toList()))),
        if (_visible.isEmpty) const Padding(padding: EdgeInsets.all(40), child: Center(child: Text('No items match this filter.'))),
      ])), bottomNavigationBar: _cartCount == 0 ? null : SafeArea(child: Padding(padding: const EdgeInsets.fromLTRB(14, 8, 14, 12), child: FilledButton.icon(onPressed: _openCart, icon: Badge(label: Text('$_cartCount'), child: const Icon(Icons.shopping_cart)), label: Text('View cart · ₹${_total.toStringAsFixed(0)}')))));
  }
  Widget _foodChip(String label, String value) => Padding(padding: const EdgeInsets.only(right: 7), child: ChoiceChip(label: Text(label), selected: _foodFilter == value, onSelected: (_) => setState(() { _foodFilter = value; _category = 'All'; })));
  Widget _itemTile(_Item i) => ListTile(contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3), leading: Text(i.symbol, style: const TextStyle(fontSize: 21)), title: Text(i.name, style: const TextStyle(fontWeight: FontWeight.w600)), subtitle: Text('${i.foodLabel}${i.momoStyle == null ? '' : ' • ${i.momoStyle}'}'), trailing: Row(mainAxisSize: MainAxisSize.min, children: [Text('₹${i.price.toStringAsFixed(0)}', style: const TextStyle(fontWeight: FontWeight.w800)), const SizedBox(width: 8), if (!i.available) const Text('Unavailable', style: TextStyle(fontSize: 12)), if (i.available) IconButton(onPressed: () => _qty(i, 1), icon: const Icon(Icons.add_circle, color: AppColors.primary))]));
  Widget _success() => Scaffold(backgroundColor: const Color(0xFFF8F7F5), body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 560), child: Padding(padding: const EdgeInsets.all(24), child: Card(child: Padding(padding: const EdgeInsets.all(26), child: Column(mainAxisSize: MainAxisSize.min, children: [const Icon(Icons.check_circle, size: 64, color: Colors.green), const SizedBox(height: 12), const Text('Order placed', style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800)), const SizedBox(height: 5), Text(_orderNumber ?? '', style: const TextStyle(fontWeight: FontWeight.w700)), const SizedBox(height: 18), Text(_statusText(), style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700)), const SizedBox(height: 6), Text('Payment: ${_paymentStatus ?? 'pending'}'), const SizedBox(height: 18), if (_paymentStatus != 'paid' && _orderStatus != 'cancelled') SizedBox(width: double.infinity, child: FilledButton.icon(onPressed: _paying ? null : _pay, icon: const Icon(Icons.lock), label: Text(_paying ? 'Opening secure checkout…' : 'Pay securely'))), const SizedBox(height: 10), OutlinedButton.icon(onPressed: () { _timer?.cancel(); setState(() { _orderNumber = null; _orderToken = null; _orderStatus = null; _paymentStatus = null; }); }, icon: const Icon(Icons.add_shopping_cart), label: const Text('Order something else'))]))))));
}
class _Item {
  const _Item({required this.id, required this.category, required this.name, required this.description, required this.price, required this.available});
  final int id; final String category; final String name; final String? description; final double price; final bool available;
  factory _Item.fromJson(Map<String, dynamic> j) => _Item(id: (j['id'] as num).toInt(), category: j['category']?.toString() ?? 'Other', name: j['name']?.toString() ?? 'Item', description: j['description']?.toString(), price: (j['price'] as num?)?.toDouble() ?? 0, available: j['available'] == true);
  String get foodType { final v = '$category $name'.toLowerCase(); return RegExp(r'\b(chicken|mutton|fish|prawn|prawns|egg|beef|pork|lollipop|wings|shawarma)\b').hasMatch(v) ? 'NON-VEG' : 'VEG'; }
  String get foodLabel => foodType == 'VEG' ? '🟢 Veg' : '🔴 Non-Veg';
  String get symbol => foodType == 'VEG' ? '🟢' : '🔴';
  String? get momoStyle { if (!name.toLowerCase().contains('momo')) return null; final v = name.toLowerCase(); if (v.contains('steamed')) return 'Steamed'; if (v.contains('chilli') || v.contains('chili')) return 'Chilli'; if (v.contains('kurkure')) return 'Kurkure'; if (v.contains('afghani')) return 'Afghani'; return null; }
  String get displayGroup { if (name.toLowerCase().contains('momo')) return 'MOMOS / ${momoStyle ?? 'Other'} / $foodType'; return category; }
}
