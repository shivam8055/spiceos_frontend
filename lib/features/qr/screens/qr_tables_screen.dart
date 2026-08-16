import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/app_shell.dart';
import '../models/qr_table.dart';
import '../repositories/qr_table_repository.dart';

final qrTableRepositoryProvider = Provider<QRTableRepository>((ref) => QRTableRepository(ref.read(apiClientProvider)));

class QRTablesScreen extends ConsumerStatefulWidget {
  const QRTablesScreen({super.key});
  @override
  ConsumerState<QRTablesScreen> createState() => _QRTablesScreenState();
}

class _QRTablesScreenState extends ConsumerState<QRTablesScreen> {
  final _branch = TextEditingController(text: 'main');
  final _tableId = TextEditingController();
  final _tableName = TextEditingController();
  final _session = TextEditingController(text: 'default');
  QRTable? _created;
  bool _saving = false;
  String? _restaurantId;
  String? _error;

  Future<void> _loadRestaurant() async {
    try {
      final response = await ref.read(apiClientProvider).get('/qr/admin/restaurant');
      if (!mounted) return;
      setState(() => _restaurantId = response.data['restaurant_id'] as String);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e.toString());
    }
  }

  Future<void> _create() async {
    final restaurantId = _restaurantId;
    if (restaurantId == null) return;
    if (_branch.text.trim().isEmpty || _tableId.text.trim().isEmpty || _tableName.text.trim().isEmpty) {
      setState(() => _error = 'Branch, table ID and table name are required.');
      return;
    }
    setState(() { _saving = true; _error = null; });
    try {
      final table = await ref.read(qrTableRepositoryProvider).create(
        restaurantId: restaurantId,
        branchId: _branch.text.trim(),
        tableId: _tableId.text.trim(),
        tableName: _tableName.text.trim(),
        sessionId: _session.text.trim().isEmpty ? 'default' : _session.text.trim(),
      );
      if (!mounted) return;
      setState(() { _created = table; _saving = false; });
    } catch (e) {
      if (!mounted) return;
      setState(() { _saving = false; _error = e.toString(); });
    }
  }

  @override
  void initState() { super.initState(); _loadRestaurant(); }

  @override
  void dispose() {
    _branch.dispose(); _tableId.dispose(); _tableName.dispose(); _session.dispose(); super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: ListView(
        children: [
          const Text('QR Table Management', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
          const SizedBox(height: 6),
          const Text('Create secure restaurant-owned QR codes for each table.'),
          const SizedBox(height: 24),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Create Table QR', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                const SizedBox(height: 18),
                Row(children: [
                  Expanded(child: TextField(controller: _branch, decoration: const InputDecoration(labelText: 'Branch ID'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _tableId, decoration: const InputDecoration(labelText: 'Table ID', hintText: 'T01'))),
                  const SizedBox(width: 12),
                  Expanded(child: TextField(controller: _tableName, decoration: const InputDecoration(labelText: 'Table name', hintText: 'Table 1'))),
                ]),
                const SizedBox(height: 12),
                SizedBox(width: 260, child: TextField(controller: _session, decoration: const InputDecoration(labelText: 'Session ID'))),
                const SizedBox(height: 18),
                FilledButton.icon(onPressed: _saving || _restaurantId == null ? null : _create, icon: const Icon(Icons.qr_code_2), label: Text(_saving ? 'Creating…' : 'Generate QR')),
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                ],
              ]),
            ),
          ),
          const SizedBox(height: 20),
          if (_created != null)
            Card(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  QrImageView(data: _created!.qrUrl, version: QrVersions.auto, size: 220),
                  const SizedBox(width: 28),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('QR created successfully', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w700)),
                    const SizedBox(height: 12),
                    Text('${_created!.tableName} • ${_created!.branchId}'),
                    const SizedBox(height: 10),
                    SelectableText(_created!.qrUrl),
                    const SizedBox(height: 12),
                    OutlinedButton.icon(
                      onPressed: () async {
                        await Clipboard.setData(ClipboardData(text: _created!.qrUrl));
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('QR URL copied.')));
                      },
                      icon: const Icon(Icons.copy), label: const Text('Copy QR URL'),
                    ),
                    const SizedBox(height: 8),
                    const Text('The token is generated by the backend and resolves to this restaurant/table. Client-side restaurant IDs are not trusted.'),
                  ])),
                ]),
              ),
            ),
        ],
      ),
    );
  }
}
