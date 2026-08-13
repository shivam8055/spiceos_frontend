import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/inventory_api_provider.dart';

class AddInventoryItemDialog extends ConsumerStatefulWidget {
  const AddInventoryItemDialog({super.key});

  @override
  ConsumerState<AddInventoryItemDialog> createState() =>
      _AddInventoryItemDialogState();
}

class _AddInventoryItemDialogState
    extends ConsumerState<AddInventoryItemDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _skuController = TextEditingController();
  final _unitController = TextEditingController(text: 'unit');
  final _quantityController = TextEditingController(text: '0');
  final _reorderController = TextEditingController(text: '0');
  final _costController = TextEditingController(text: '0');

  bool _saving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _skuController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    _reorderController.dispose();
    _costController.dispose();
    super.dispose();
  }

  String? _required(String? value, String label) {
    if (value == null || value.trim().isEmpty) return '$label is required';
    return null;
  }

  String? _number(String? value, String label) {
    final parsed = double.tryParse(value?.trim() ?? '');
    if (parsed == null || parsed < 0) return '$label must be 0 or more';
    return null;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _saving = true);

    try {
      await createInventoryItem(
        ref,
        name: _nameController.text.trim(),
        sku: _skuController.text.trim().isEmpty
            ? null
            : _skuController.text.trim(),
        unit: _unitController.text.trim(),
        quantity: double.parse(_quantityController.text.trim()),
        reorderLevel: double.parse(_reorderController.text.trim()),
        costPerUnit: double.parse(_costController.text.trim()),
      );

      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Unable to create item: $error'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Inventory Item'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextFormField(
                  controller: _nameController,
                  enabled: !_saving,
                  autofocus: true,
                  decoration: const InputDecoration(
                    labelText: 'Item name',
                    hintText: 'e.g. Basmati Rice',
                  ),
                  validator: (value) => _required(value, 'Item name'),
                ),
                const SizedBox(height: 14),
                TextFormField(
                  controller: _skuController,
                  enabled: !_saving,
                  decoration: const InputDecoration(
                    labelText: 'SKU',
                    hintText: 'Optional',
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _unitController,
                        enabled: !_saving,
                        decoration: const InputDecoration(labelText: 'Unit'),
                        validator: (value) => _required(value, 'Unit'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextFormField(
                        controller: _quantityController,
                        enabled: !_saving,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(labelText: 'Opening stock'),
                        validator: (value) => _number(value, 'Opening stock'),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _reorderController,
                        enabled: !_saving,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration:
                            const InputDecoration(labelText: 'Reorder level'),
                        validator: (value) => _number(value, 'Reorder level'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: TextFormField(
                        controller: _costController,
                        enabled: !_saving,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Cost per unit',
                          prefixText: '₹ ',
                        ),
                        validator: (value) => _number(value, 'Cost per unit'),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: _saving ? null : () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),
        FilledButton.icon(
          onPressed: _saving ? null : _save,
          icon: _saving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.check),
          label: Text(_saving ? 'Saving...' : 'Create Item'),
        ),
      ],
    );
  }
}
