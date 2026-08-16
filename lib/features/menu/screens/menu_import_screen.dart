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

    setState(() {
      _busy = true;
      _error = null;
      _fileName = result.files.single.name;
      _items = [];
      _warnings = [];
    });

    try {
      final restaurant = await ref.read(apiClientProvider).get('/qr/admin/restaurant');
      final restaurantId = restaurant.data['restaurant_id'] as String;
      final file = result.files.single;
      final form = FormData.fromMap({
        'restaurant_id': restaurantId,
        'branch_id': _branch.text.trim(),
        'file': MultipartFile.fromBytes(file.bytes!, filename: file.name),
      });
      final response = await ref.read(apiClientProvider).postMultipart('/qr/admin/menu-import/preview', form);
      final data = Map<String, dynamic>.from(response.data as Map);
      if (!mounted) return;
      setState(() {
        _restaurantId = restaurantId;
        _items = (data['items'] as List? ?? []).map((e) => Map<String, dynamic>.from(e as Map)).toList();
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
      setState(() { _busy = false; _error = e.toString(); });
    }
  }

  Future<void> _confirm() async {
    if (_restaurantId == null || _items.isEmpty) return;
    setState(() { _busy = true; _error = null; });
    try {
      await ref.read(apiClientProvider).post('/qr/admin/menu-import/confirm', {
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
      setState(() { _busy = false; _error = detail ?? 'Unable to publish the menu.'; });
    }
  }

  @override
  void dispose() { _branch.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Import Menu with AI')),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 900),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('Upload your existing restaurant menu', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              const Text('SpiceOS reads the menu image, extracts categories, items and prices, then lets you review before publishing.'),
              const SizedBox(height: 24),
              Row(children: [
                SizedBox(width: 220, child: TextField(controller: _branch, decoration: const InputDecoration(labelText: 'Branch ID'))),
                const SizedBox(width: 16),
                FilledButton.icon(onPressed: _busy ? null : _pickAndExtract, icon: const Icon(Icons.upload_file), label: Text(_busy ? 'Processing…' : 'Upload Menu')),
                if (_fileName != null) ...[const SizedBox(width: 12), Expanded(child: Text(_fileName!))],
              ]),
              if (_error != null) ...[const SizedBox(height: 16), Text(_error!, style: const TextStyle(color: AppColors.error))],
              if (_warnings.isNotEmpty) ...[const SizedBox(height: 16), Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const Text('Review warnings', style: TextStyle(fontWeight: FontWeight.w700)), ..._warnings.map((w) => Text('• $w'))])) )],
              const SizedBox(height: 16),
              Expanded(child: Card(child: _items.isEmpty ? const Center(child: Text('Upload a clear JPG, PNG or WEBP menu image to preview the extracted items.')) : ListView.separated(
                padding: const EdgeInsets.all(12),
                itemCount: _items.length,
                separatorBuilder: (_, __) => const Divider(),
                itemBuilder: (_, i) {
                  final item = _items[i];
                  return ListTile(
                    leading: CircleAvatar(backgroundColor: AppColors.primary.withValues(alpha: .1), child: const Icon(Icons.restaurant_menu, color: AppColors.primary)),
                    title: Text(item['name']?.toString() ?? '', style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text(item['category']?.toString() ?? ''),
                    trailing: Text('₹${item['price']}', style: const TextStyle(fontWeight: FontWeight.w700)),
                  );
                },
              ))),
              if (_items.isNotEmpty) ...[
                const SizedBox(height: 16),
                Align(alignment: Alignment.centerRight, child: FilledButton.icon(onPressed: _busy ? null : _confirm, icon: const Icon(Icons.publish), label: Text(_busy ? 'Publishing…' : 'Review Complete — Publish Menu'))),
              ],
            ]),
          ),
        ),
      ),
    );
  }
}
