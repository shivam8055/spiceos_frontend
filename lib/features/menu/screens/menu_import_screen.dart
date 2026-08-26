import 'package:dio/dio.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/network/api_client.dart';
import '../../../core/theme/app_colors.dart';

class MenuImportScreen extends ConsumerStatefulWidget {
  const MenuImportScreen({super.key});

  @override
  ConsumerState<MenuImportScreen> createState() => _MenuImportScreenState();
}

class _MenuImportScreenState extends ConsumerState<MenuImportScreen> {
  final _branch = TextEditingController(text: 'main');
  String? _restaurantId;
  List<Map<String, dynamic>> _items = [];
  List<String> _warnings = [];
  String? _fileName;
  bool _busy = false;
  String? _error;

  Future<void> _pickAndExtract() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'webp'],
      withData: true,
    );
    if (result == null || result.files.single.bytes == null) return;

    final branch = _branch.text.trim();
    if (branch.isEmpty) {
      setState(() => _error = 'Enter a branch ID before importing the menu.');
      return;
    }

    setState(() {
      _busy = true;
      _error = null;
      _fileName = result.files.single.name;
      _items = [];
      _warnings = [];
    });

    try {
      // Backend QR admin routes are mounted at /admin/*, not /qr/admin/*.
      final restaurant = await ref.read(apiClientProvider).get('/admin/restaurant');
      final restaurantId = restaurant.data['restaurant_id'] as String;
      final file = result.files.single;
      final form = FormData.fromMap({
        'restaurant_id': restaurantId,
        'branch_id': branch,
        'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
      });
      final response = await ref.read(apiClientProvider).postMultipart('/admin/menu-import/preview', form);
      final data = Map<String, dynamic>.from(response.data as Map);
      if (!mounted) return;
      setState(() {
        _restaurantId = restaurantId;
        _items = (data['items'] as List? ?? [])
            .map((e) => Map<String, dynamic>.from(e as Map))
            .toList();
        _warnings = (data['warnings'] as List? ?? []).map((e) => e.toString()).toList();
        _busy = false;
      });
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data is Map ? e.response?.data['detail']?.toString() : null;
      setState(() {
        _busy = false;
        _error = detail ?? 'Unable to extract the menu.';
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _busy = false;
        _error = e.toString();
      });
    }
  }

  Future<void> _editItem(int index) async {
    final item = Map<String, dynamic>.from(_items[index]);
    final category = TextEditingController(text: item['category']?.toString() ?? '');
    final name = TextEditingController(text: item['name']?.toString() ?? '');
    final description = TextEditingController(text: item['description']?.toString() ?? '');
    final price = TextEditingController(text: item['price']?.toString() ?? '');

    final saved = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Review menu item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: category, decoration: const InputDecoration(labelText: 'Category')),
              const SizedBox(height: 12),
              TextField(controller: name, decoration: const InputDecoration(labelText: 'Item name')),
              const SizedBox(height: 12),
              TextField(controller: description, decoration: const InputDecoration(labelText: 'Description')),
              const SizedBox(height: 12),
              TextField(
                controller: price,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Price (₹)'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(context, true), child: const Text('Save')),
        ],
      ),
    );

    if (saved == true && mounted) {
      final parsedPrice = double.tryParse(price.text.trim());
      if (category.text.trim().isEmpty || name.text.trim().isEmpty || parsedPrice == null || parsedPrice < 0) {
        setState(() => _error = 'Category, item name and a valid non-negative price are required.');
      } else {
        setState(() {
          _items[index] = {
            ...item,
            'category': category.text.trim(),
            'name': name.text.trim(),
            'description': description.text.trim().isEmpty ? null : description.text.trim(),
            'price': parsedPrice,
            'available': item['available'] ?? true,
          };
          _error = null;
        });
      }
    }

    category.dispose();
    name.dispose();
    description.dispose();
    price.dispose();
  }

  void _removeItem(int index) {
    setState(() => _items.removeAt(index));
  }

  Future<void> _confirm() async {
    if (_restaurantId == null || _items.isEmpty) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await ref.read(apiClientProvider).post('/admin/menu-import/confirm', {
        'restaurant_id': _restaurantId,
        'branch_id': _branch.text.trim(),
        'items': _items,
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Menu imported successfully.')));
      context.go('/menu');
    } on DioException catch (e) {
      if (!mounted) return;
      final detail = e.response?.data is Map ? e.response?.data['detail']?.toString() : null;
      setState(() {
        _busy = false;
        _error = detail ?? 'Unable to publish the menu.';
      });
    }
  }

  @override
  void dispose() {
    _branch.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Menu with AI')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1000),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Upload your existing restaurant menu', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                const SizedBox(height: 8),
                const Text('SpiceOS reads the menu image, extracts categories, items and prices, then lets you review every item before publishing.'),
                const SizedBox(height: 24),
                Row(
                  children: [
                    SizedBox(width: 220, child: TextField(controller: _branch, decoration: const InputDecoration(labelText: 'Branch ID'))),
                    const SizedBox(width: 16),
                    FilledButton.icon(onPressed: _busy ? null : _pickAndExtract, icon: const Icon(Icons.upload_file), label: Text(_busy ? 'Processing…' : 'Upload Menu')),
                    if (_fileName != null) ...[
                      const SizedBox(width: 12),
                      Expanded(child: Text(_fileName!, overflow: TextOverflow.ellipsis)),
                    ],
                  ],
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(children: [
                        const Icon(Icons.error_outline, color: AppColors.error),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_error!, style: const TextStyle(color: AppColors.error))),
                      ]),
                    ),
                  ),
                ],
                if (_warnings.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Text('Review warnings', style: TextStyle(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        ..._warnings.map((w) => Padding(padding: const EdgeInsets.only(bottom: 4), child: Text('• $w'))),
                      ]),
                    ),
                  ),
                ],
                if (_items.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Text('${_items.length} items extracted', style: const TextStyle(fontWeight: FontWeight.w700)),
                      const Spacer(),
                      const Text('Review and edit before publishing'),
                    ],
                  ),
                ],
                const SizedBox(height: 12),
                Expanded(
                  child: Card(
                    child: _items.isEmpty
                        ? const Center(child: Text('Upload a clear JPG, PNG or WEBP menu image to preview the extracted items.'))
                        : ListView.separated(
                            padding: const EdgeInsets.all(12),
                            itemCount: _items.length,
                            separatorBuilder: (_, __) => const Divider(),
                            itemBuilder: (_, i) {
                              final item = _items[i];
                              return ListTile(
                                leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: .1), child: const Icon(Icons.restaurant_menu, color: AppColors.primary)),
                                title: Text(item['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                                subtitle: Text('${item['category']?.toString() ?? ''}${item['description'] == null ? '' : ' • ${item['description']}'}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text('₹${item['price']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                                    IconButton(tooltip: 'Edit', onPressed: _busy ? null : () => _editItem(i), icon: const Icon(Icons.edit_outlined)),
                                    IconButton(tooltip: 'Remove', onPressed: _busy ? null : () => _removeItem(i), icon: const Icon(Icons.delete_outline)),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ),
                if (_items.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: FilledButton.icon(
                      onPressed: _busy ? null : _confirm,
                      icon: const Icon(Icons.publish),
                      label: Text(_busy ? 'Publishing…' : 'Publish ${_items.length} Items'),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
