import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';
import '../services/payment_checkout.dart';

class QRCustomerMenuScreen extends ConsumerStatefulWidget {
  const QRCustomerMenuScreen({super.key, required this.token});

  final String token;

  @override
  ConsumerState<QRCustomerMenuScreen> createState() => _QRCustomerMenuScreenState();
}

class _QRCustomerMenuScreenState extends ConsumerState<QRCustomerMenuScreen> {
  Map<String, dynamic> _context = const {};
  List<_Item> _items = const [];
  final Map<int, int> _cart = <int, int>{};
  final TextEditingController _searchController = TextEditingController();

  String _category = 'All';
  String _foodFilter = 'All';
  bool _loading = true;
  bool _placing = false;
  bool _paying = false;
  bool _gettingLocation = false;

  String? _error;
  String? _orderNumber;
  String? _orderToken;
  String? _orderStatus;
  String? _paymentStatus;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (mounted) {
      setState(() {
        _loading = true;
        _error = null;
      });
    }
    try {
      final response = await ref
          .read(apiClientProvider)
          .get('/qr/public/qr/${widget.token}/menu');
      final data = Map<String, dynamic>.from(response.data as Map);
      final rawItems = data['items'] as List? ?? const [];
      final items = rawItems
          .map((value) => _Item.fromJson(Map<String, dynamic>.from(value as Map)))
          .toList();
      if (!mounted) return;
      setState(() {
        _context = Map<String, dynamic>.from(data['context'] as Map? ?? const {});
        _items = items;
        _loading = false;
      });
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = _message(error);
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'Unable to load this menu. Please scan the table QR again.';
      });
    }
  }

  String _message(DioException error) {
    final data = error.response?.data;
    if (data is Map && data['detail'] != null) {
      return data['detail'].toString();
    }
    return 'Something went wrong. Please try again.';
  }

  List<_Item> get _visibleItems {
    return _items.where((item) {
      final categoryMatches = _category == 'All' || item.category == _category;
      final foodMatches = _foodFilter == 'All' || item.foodType == _foodFilter;
      final query = _searchController.text.trim().toLowerCase();
      final searchMatches = query.isEmpty || item.name.toLowerCase().contains(query) || item.category.toLowerCase().contains(query) || (item.description?.toLowerCase().contains(query) ?? false);
      return categoryMatches && foodMatches && searchMatches;
    }).toList();
  }

  List<String> get _categories {
    final values = <String>{};
    for (final item in _items) {
      if (item.category.isNotEmpty) values.add(item.category);
    }
    return ['All', ...values];
  }

  Map<String, List<_Item>> get _groups {
    final result = <String, List<_Item>>{};
    for (final item in _visibleItems) {
      result.putIfAbsent(item.displayGroup, () => <_Item>[]).add(item);
    }
    return result;
  }

  int get _cartCount => _cart.values.fold(0, (sum, value) => sum + value);

  double get _total {
    return _items.fold<double>(
      0,
      (sum, item) => sum + item.price * (_cart[item.id] ?? 0),
    );
  }

  void _qty(_Item item, int delta) {
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
    final addressController = TextEditingController();
    final landmarkController = TextEditingController();
    final cityController = TextEditingController(text: 'Patna');
    final pinController = TextEditingController();
    final instructionController = TextEditingController();
    double? latitude;
    double? longitude;
    bool delivery = true;

    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, setSheet) {
          final selected = _items.where((item) => _cart.containsKey(item.id)).toList();
          return Padding(
            padding: EdgeInsets.fromLTRB(18, 18, 18, MediaQuery.of(context).viewInsets.bottom + 18),
            child: SafeArea(
              top: false,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(children: [
                      const Expanded(child: Text('Your order', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800))),
                      IconButton(onPressed: () => Navigator.pop(sheetContext), icon: const Icon(Icons.close)),
                    ]),
                    ...selected.map((item) => ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Text(item.symbol, style: const TextStyle(fontSize: 20)),
                      title: Text(item.name),
                      subtitle: Text('₹${item.price.toStringAsFixed(0)} each'),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        IconButton(onPressed: () { _qty(item, -1); setSheet(() {}); }, icon: const Icon(Icons.remove_circle_outline)),
                        Text('${_cart[item.id] ?? 0}'),
                        IconButton(onPressed: () { _qty(item, 1); setSheet(() {}); }, icon: const Icon(Icons.add_circle_outline)),
                      ]),
                    )),
                    const SizedBox(height: 8),
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name *', border: OutlineInputBorder())),
                    const SizedBox(height: 10),
                    TextField(controller: phoneController, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: '10-digit phone *', border: OutlineInputBorder())),
                    const SizedBox(height: 12),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Delivery to address'),
                      subtitle: const Text('Turn off for pickup'),
                      value: delivery,
                      onChanged: (value) => setSheet(() => delivery = value),
                    ),
                    if (delivery) ...[
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          onPressed: _gettingLocation ? null : () async {
                            setSheet(() => _gettingLocation = true);
                            try {
                              if (!await Geolocator.isLocationServiceEnabled()) {
                                throw Exception('Please turn on your phone location/GPS.');
                              }
                              var permission = await Geolocator.checkPermission();
                              if (permission == LocationPermission.denied) {
                                permission = await Geolocator.requestPermission();
                              }
                              if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
                                throw Exception('Allow location access in your phone settings.');
                              }
                              final position = await Geolocator.getCurrentPosition(
                                locationSettings: const LocationSettings(accuracy: LocationAccuracy.high),
                              );
                              latitude = position.latitude;
                              longitude = position.longitude;
                              addressController.text = 'GPS pin: ${position.latitude.toStringAsFixed(6)}, ${position.longitude.toStringAsFixed(6)}';
                              setSheet(() {});
                            } catch (error) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text(error.toString().replaceFirst('Exception: ', ''))),
                                );
                              }
                            } finally {
                              setSheet(() => _gettingLocation = false);
                            }
                          },
                          icon: _gettingLocation
                              ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Icon(Icons.my_location),
                          label: Text(_gettingLocation ? 'Getting GPS location…' : latitude == null ? 'Use my current GPS location' : 'GPS location captured ✓'),
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextField(controller: addressController, decoration: const InputDecoration(labelText: 'House / street / area or GPS pin *', border: OutlineInputBorder())),
                      const SizedBox(height: 8),
                      TextField(controller: landmarkController, decoration: const InputDecoration(labelText: 'Landmark (optional)', border: OutlineInputBorder())),
                      const SizedBox(height: 8),
                      Row(children: [
                        Expanded(child: TextField(controller: cityController, decoration: const InputDecoration(labelText: 'City *', border: OutlineInputBorder()))),
                        const SizedBox(width: 8),
                        SizedBox(width: 110, child: TextField(controller: pinController, keyboardType: TextInputType.number, maxLength: 6, decoration: const InputDecoration(labelText: 'PIN *', counterText: '', border: OutlineInputBorder()))),
                      ]),
                      const SizedBox(height: 8),
                      TextField(controller: instructionController, decoration: const InputDecoration(labelText: 'Delivery instructions (optional)', border: OutlineInputBorder())),
                    ],
                    const SizedBox(height: 14),
                    Row(children: [
                      const Expanded(child: Text('Total', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800))),
                      Text('₹${_total.toStringAsFixed(0)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
                    ]),
                    const SizedBox(height: 14),
                    SizedBox(width: double.infinity, child: FilledButton.icon(
                      onPressed: _placing ? null : () async {
                        final name = nameController.text.trim();
                        final phone = phoneController.text.trim();
                        final address = addressController.text.trim();
                        final city = cityController.text.trim();
                        final pin = pinController.text.trim();
                        final validPhone = phone.length == 10 && phone.codeUnits.every((digit) => digit >= 48 && digit <= 57);
                        if (name.isEmpty || !validPhone) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter your name and valid 10-digit phone number.')));
                          return;
                        }
                        final validPin = pin.length == 6 && pin.codeUnits.every((digit) => digit >= 48 && digit <= 57);
                        if (delivery && (address.isEmpty || city.isEmpty || (latitude == null && !validPin))) {
                          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Enter address, city and valid 6-digit PIN.')));
                          return;
                        }
                        await _place(name, phone, delivery: delivery, address: address, landmark: landmarkController.text.trim(), city: city, pin: pin, instructions: instructionController.text.trim(), latitude: latitude, longitude: longitude);
                        if (mounted && _orderNumber != null) Navigator.pop(sheetContext);
                      },
                      icon: const Icon(Icons.receipt_long),
                      label: Text(_placing ? 'Placing order…' : 'Place order · ₹${_total.toStringAsFixed(0)}'),
                    )),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
    nameController.dispose();
    phoneController.dispose();
    addressController.dispose();
    landmarkController.dispose();
    cityController.dispose();
    pinController.dispose();
    instructionController.dispose();
  }

  Future<void> _place(String? name, String? phone, {required bool delivery, String? address, String? landmark, String? city, String? pin, String? instructions, double? latitude, double? longitude}) async {
    setState(() => _placing = true);
    try {
      final response = await ref.read(apiClientProvider).postWithHeaders(
        '/qr/public/qr/${widget.token}/orders',
        {
          'items': _cart.entries
              .map(
                (entry) => {
                  'menu_item_id': entry.key,
                  'quantity': entry.value,
                  'modifier_ids': <String>[],
                },
              )
              .toList(),
          'customer_name': name,
          'customer_phone': phone,
          'fulfillment_type': delivery ? 'delivery' : 'pickup',
          if (delivery) 'delivery_address': {'address_line': address, 'landmark': landmark, 'city': city, 'postal_code': pin, 'delivery_instructions': instructions, if (latitude != null && longitude != null) 'latitude': latitude, if (latitude != null && longitude != null) 'longitude': longitude, if (latitude != null && longitude != null) 'google_maps_url': 'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude'},
        },
        headers: {
          'Idempotency-Key': 'qr-${DateTime.now().microsecondsSinceEpoch}',
        },
      );
      final data = Map<String, dynamic>.from(response.data as Map);
      if (!mounted) return;
      setState(() {
        _orderNumber = data['order_number']?.toString();
        _orderToken = data['public_order_token']?.toString();
        _orderStatus = data['status']?.toString() ?? 'created';
        _paymentStatus = 'pending';
        _cart.clear();
        _placing = false;
      });
      _poll();
    } on DioException catch (error) {
      if (!mounted) return;
      setState(() => _placing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_message(error))),
      );
    } catch (error) {
      if (!mounted) return;
      setState(() => _placing = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  void _poll() {
    _timer?.cancel();
    _loadStatus();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) => _loadStatus());
  }

  Future<void> _loadStatus() async {
    final token = _orderToken;
    if (token == null) return;
    try {
      final response = await ref.read(apiClientProvider).get('/qr/public/orders/$token');
      final data = Map<String, dynamic>.from(response.data as Map);
      if (!mounted) return;
      setState(() {
        _orderStatus = data['status']?.toString() ?? _orderStatus;
        _paymentStatus = data['payment_status']?.toString() ?? _paymentStatus;
      });
      if (_orderStatus == 'delivered' || _orderStatus == 'cancelled') {
        _timer?.cancel();
      }
    } catch (_) {
      // Status polling is best-effort and should not interrupt ordering.
    }
  }

  Future<void> _pay() async {
    final token = _orderToken;
    if (token == null || _paying) return;
    setState(() => _paying = true);
    try {
      final response = await ref
          .read(apiClientProvider)
          .post('/qr/public/orders/$token/payment');
      final payment = Map<String, dynamic>.from(response.data as Map);
      final result = await PaymentCheckout().open(
        keyId: payment['key_id'].toString(),
        amount: payment['amount_paise'].toString(),
        currency: payment['currency'].toString(),
        orderId: payment['provider_order_id'].toString(),
        name: _context['restaurant_name']?.toString() ?? 'SpiceOS',
      );
      if (result == null) return;
      await ref.read(apiClientProvider).post(
        '/qr/public/orders/$token/payment/verify',
        {
          'provider_order_id': result['razorpay_order_id'],
          'provider_payment_id': result['razorpay_payment_id'],
          'signature': result['razorpay_signature'],
        },
      );
      await _loadStatus();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(error.toString().replaceFirst('Bad state: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _paying = false);
    }
  }

  String _statusText() {
    switch (_orderStatus) {
      case 'preparing':
        return 'Preparing';
      case 'ready':
        return 'Ready';
      case 'outForDelivery':
        return 'On the way';
      case 'delivered':
        return 'Delivered';
      case 'cancelled':
        return 'Cancelled';
      default:
        return 'Order received';
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_orderNumber != null) return _success();

    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _context['restaurant_name']?.toString() ?? 'SpiceOS',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            if (_context['table_name'] != null)
              Text(
                'Table ${_context['table_name']}',
                style: const TextStyle(fontSize: 12),
              ),
          ],
        ),
        actions: [
          IconButton(onPressed: _load, icon: const Icon(Icons.refresh)),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Text(_error!),
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(14, 14, 14, 100),
                    children: [
                      Container(
                        padding: const EdgeInsets.all(18),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFEDE4),
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Order from your table',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              'Choose a category or filter Veg / Non-Veg, then add items to your cart.',
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),
                      TextField(
                        controller: _searchController,
                        onChanged: (_) => setState(() {}),
                        decoration: InputDecoration(
                          hintText: 'Search dishes…',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isEmpty ? null : IconButton(
                            onPressed: () { _searchController.clear(); setState(() {}); },
                            icon: const Icon(Icons.close),
                          ),
                          filled: true,
                          fillColor: Colors.white,
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 44,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          children: [
                            _foodChip('All', 'All'),
                            _foodChip('🟢 Veg', 'VEG'),
                            _foodChip('🔴 Non-Veg', 'NON-VEG'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 42,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: _categories.length,
                          separatorBuilder: (_, __) => const SizedBox(width: 7),
                          itemBuilder: (context, index) {
                            final category = _categories[index];
                            return ChoiceChip(
                              label: Text(category.replaceAll(' / ', ' • ')),
                              selected: _category == category,
                              onSelected: (_) => setState(() => _category = category),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 14),
                      ..._groups.entries.map(
                        (entry) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          elevation: 0,
                          child: ExpansionTile(
                            initiallyExpanded: true,
                            title: Text(
                              entry.key.replaceAll(' / ', ' • '),
                              style: const TextStyle(fontWeight: FontWeight.w800),
                            ),
                            subtitle: Text('${entry.value.length} items'),
                            children: entry.value.map(_itemTile).toList(),
                          ),
                        ),
                      ),
                      if (_visibleItems.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(child: Text('No items match this filter.')),
                        ),
                    ],
                  ),
                ),
      bottomNavigationBar: _cartCount == 0
          ? null
          : SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 8, 14, 12),
                child: FilledButton.icon(
                  onPressed: _openCart,
                  icon: Badge(
                    label: Text('$_cartCount'),
                    child: const Icon(Icons.shopping_cart),
                  ),
                  label: Text('View cart · ₹${_total.toStringAsFixed(0)}'),
                ),
              ),
            ),
    );
  }

  Widget _foodChip(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(right: 7),
      child: ChoiceChip(
        label: Text(label),
        selected: _foodFilter == value,
        onSelected: (_) {
          setState(() {
            _foodFilter = value;
            _category = 'All';
          });
        },
      ),
    );
  }

  Widget _itemTile(_Item item) {
    final quantity = _cart[item.id] ?? 0;
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 3),
      leading: Text(item.symbol, style: const TextStyle(fontSize: 21)),
      title: Text(
        item.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: Text(
        '${item.foodLabel}${item.momoStyle == null ? '' : ' • ${item.momoStyle}'}',
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '₹${item.price.toStringAsFixed(0)}',
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          const SizedBox(width: 8),
          if (!item.available)
            const Text('Unavailable', style: TextStyle(fontSize: 12)),
          if (item.available && quantity == 0)
            IconButton(
              tooltip: 'Add to cart',
              onPressed: () => _qty(item, 1),
              icon: const Icon(Icons.add_circle, color: AppColors.primary),
            ),
          if (item.available && quantity > 0)
            Container(
              decoration: BoxDecoration(color: AppColors.primary.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(20)),
              child: Row(mainAxisSize: MainAxisSize.min, children: [
                IconButton(tooltip: 'Remove one', visualDensity: VisualDensity.compact, onPressed: () => _qty(item, -1), icon: const Icon(Icons.remove, size: 18)),
                Text('$quantity', style: const TextStyle(fontWeight: FontWeight.w800)),
                IconButton(tooltip: 'Add one', visualDensity: VisualDensity.compact, onPressed: () => _qty(item, 1), icon: const Icon(Icons.add, size: 18)),
              ]),
            ),
        ],
      ),
    );
  }

  Widget _success() {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F7F5),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 560),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(26),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.check_circle, size: 64, color: Colors.green),
                    const SizedBox(height: 12),
                    const Text(
                      'Order placed',
                      style: TextStyle(fontSize: 26, fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      _orderNumber ?? '',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 18),
                    Text(
                      _statusText(),
                      style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(height: 6),
                    Text('Payment: ${_paymentStatus ?? 'pending'}'),
                    const SizedBox(height: 18),
                    if (_paymentStatus != 'paid' && _orderStatus != 'cancelled')
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: _paying ? null : _pay,
                          icon: const Icon(Icons.lock),
                          label: Text(
                            _paying
                                ? 'Opening secure checkout…'
                                : 'Pay securely',
                          ),
                        ),
                      ),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: () {
                        _timer?.cancel();
                        setState(() {
                          _orderNumber = null;
                          _orderToken = null;
                          _orderStatus = null;
                          _paymentStatus = null;
                        });
                      },
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

class _Item {
  const _Item({
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

  factory _Item.fromJson(Map<String, dynamic> json) {
    return _Item(
      id: (json['id'] as num).toInt(),
      category: json['category']?.toString() ?? 'Other',
      name: json['name']?.toString() ?? 'Item',
      description: json['description']?.toString(),
      price: (json['price'] as num?)?.toDouble() ?? 0,
      available: json['available'] == true,
    );
  }

  String get foodType {
    final value = '$category $name'.toLowerCase();
    final nonVeg = RegExp(
      r'\b(chicken|mutton|fish|prawn|prawns|egg|beef|pork|lollipop|wings|shawarma)\b',
    );
    return nonVeg.hasMatch(value) ? 'NON-VEG' : 'VEG';
  }

  String get foodLabel => foodType == 'VEG' ? '🟢 Veg' : '🔴 Non-Veg';

  String get symbol => foodType == 'VEG' ? '🟢' : '🔴';

  String? get momoStyle {
    final value = name.toLowerCase();
    if (!value.contains('momo')) return null;
    if (value.contains('steamed')) return 'Steamed';
    if (value.contains('chilli') || value.contains('chili')) return 'Chilli';
    if (value.contains('kurkure')) return 'Kurkure';
    if (value.contains('afghani')) return 'Afghani';
    return null;
  }

  String get displayGroup {
    if (name.toLowerCase().contains('momo')) {
      return 'MOMOS / ${momoStyle ?? 'Other'} / $foodType';
    }
    return category;
  }
}