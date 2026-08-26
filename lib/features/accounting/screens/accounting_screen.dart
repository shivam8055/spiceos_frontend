import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/app_shell.dart';

class AccountingScreen extends ConsumerStatefulWidget {
  const AccountingScreen({super.key});

  @override
  ConsumerState<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends ConsumerState<AccountingScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabs;

  bool loading = false;
  Map<String, dynamic> gst = {};
  Map<String, dynamic> profile = {};
  List<dynamic> sales = [];
  List<dynamic> purchases = [];
  List<dynamic> expenses = [];

  final _salesSubtotal = TextEditingController();
  final _salesCgst = TextEditingController();
  final _salesSgst = TextEditingController();
  final _salesTotal = TextEditingController();
  final _salesCustomer = TextEditingController(text: 'Walk-in Customer');
  final _salesPhone = TextEditingController();
  final _salesGstin = TextEditingController();

  final _purchaseBill = TextEditingController();
  final _vendor = TextEditingController();
  final _vendorGstin = TextEditingController();
  final _purchaseSubtotal = TextEditingController();
  final _purchaseCgst = TextEditingController();
  final _purchaseSgst = TextEditingController();
  final _purchaseTotal = TextEditingController();

  final _expenseCategory = TextEditingController();
  final _expenseDescription = TextEditingController();
  final _expenseAmount = TextEditingController();
  final _expenseGst = TextEditingController();

  final _legalName = TextEditingController();
  final _tradeName = TextEditingController();
  final _gstin = TextEditingController();
  final _pan = TextEditingController();
  final _address = TextEditingController();
  final _pincode = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();

  String _businessType = 'Proprietorship';
  String _state = 'Bihar';
  String _stateCode = '10';
  String _filingFrequency = 'Monthly';
  bool _composition = false;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 7, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final controller in [
      _salesSubtotal,
      _salesCgst,
      _salesSgst,
      _salesTotal,
      _salesCustomer,
      _salesPhone,
      _salesGstin,
      _purchaseBill,
      _vendor,
      _vendorGstin,
      _purchaseSubtotal,
      _purchaseCgst,
      _purchaseSgst,
      _purchaseTotal,
      _expenseCategory,
      _expenseDescription,
      _expenseAmount,
      _expenseGst,
      _legalName,
      _tradeName,
      _gstin,
      _pan,
      _address,
      _pincode,
      _phone,
      _email,
    ]) {
      controller.dispose();
    }
    super.dispose();
  }

  double _number(dynamic value) {
    if (value is num) return value.toDouble();
    return double.tryParse('$value') ?? 0;
  }

  double _controllerNumber(TextEditingController controller) {
    return _number(controller.text.trim());
  }

  String _money(dynamic value) => '₹${_number(value).toStringAsFixed(2)}';

  String _date(dynamic value) {
    final parsed = DateTime.tryParse('$value');
    if (parsed == null) return '-';
    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
  }

  Future<void> _loadAll() async {
    if (mounted) setState(() => loading = true);
    final api = ref.read(apiClientProvider);
    try {
      final responses = await Future.wait([
        api.get('/accounting/gst-summary'),
        api.get('/accounting/gst-profile'),
        api.get('/accounting/sales-invoices'),
        api.get('/accounting/purchase-invoices'),
        api.get('/accounting/expenses'),
      ]);
      if (!mounted) return;
      setState(() {
        gst = Map<String, dynamic>.from(responses[0].data as Map);
        profile = Map<String, dynamic>.from(responses[1].data as Map);
        sales = List<dynamic>.from(responses[2].data as List);
        purchases = List<dynamic>.from(responses[3].data as List);
        expenses = List<dynamic>.from(responses[4].data as List);
      });
      _applyProfile(profile);
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Accounting load failed: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _applyProfile(Map<String, dynamic> value) {
    _legalName.text = value['legal_name']?.toString() ?? '';
    _tradeName.text = value['trade_name']?.toString() ?? '';
    _gstin.text = value['gstin']?.toString() ?? '';
    _pan.text = value['pan']?.toString() ?? '';
    _address.text = value['address']?.toString() ?? '';
    _pincode.text = value['pincode']?.toString() ?? '';
    _phone.text = value['phone']?.toString() ?? '';
    _email.text = value['email']?.toString() ?? '';
    if (value['business_type'] != null) {
      _businessType = value['business_type'].toString();
    }
    if (value['state'] != null) _state = value['state'].toString();
    if (value['state_code'] != null) _stateCode = value['state_code'].toString();
    if (value['filing_frequency'] != null) {
      _filingFrequency = value['filing_frequency'].toString();
    }
    _composition = value['composition_scheme'] == true;
  }

  Future<void> _saveProfile() async {
    try {
      final response = await ref.read(apiClientProvider).put(
        '/accounting/gst-profile',
        {
          'legal_name': _legalName.text.trim(),
          'trade_name': _tradeName.text.trim(),
          'gstin': _gstin.text.trim().isEmpty
              ? null
              : _gstin.text.trim().toUpperCase(),
          'pan': _pan.text.trim().isEmpty ? null : _pan.text.trim().toUpperCase(),
          'business_type': _businessType,
          'state': _state,
          'state_code': _stateCode,
          'address': _address.text.trim(),
          'pincode': _pincode.text.trim(),
          'phone': _phone.text.trim(),
          'email': _email.text.trim(),
          'filing_frequency': _filingFrequency,
          'composition_scheme': _composition,
        },
      );
      if (!mounted) return;
      setState(() {
        profile = Map<String, dynamic>.from(response.data as Map);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('GST business profile saved')),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to save GST profile: $error')),
        );
      }
    }
  }

  Future<void> _createSale() async {
    final subtotal = _controllerNumber(_salesSubtotal);
    final cgst = _controllerNumber(_salesCgst);
    final sgst = _controllerNumber(_salesSgst);
    final total = _salesTotal.text.trim().isEmpty
        ? subtotal + cgst + sgst
        : _controllerNumber(_salesTotal);
    if (subtotal <= 0 || total <= 0) return;

    try {
      await ref.read(apiClientProvider).post(
        '/accounting/sales-invoices',
        {
          'subtotal': subtotal,
          'cgst': cgst,
          'sgst': sgst,
          'igst': 0,
          'discount': 0,
          'total': total,
          'payment_status': 'paid',
          'customer_name': _salesCustomer.text.trim().isEmpty
              ? 'Walk-in Customer'
              : _salesCustomer.text.trim(),
          'customer_phone': _salesPhone.text.trim().isEmpty
              ? null
              : _salesPhone.text.trim(),
          'customer_gstin': _salesGstin.text.trim().isEmpty
              ? null
              : _salesGstin.text.trim().toUpperCase(),
        },
      );
      _clear([
        _salesSubtotal,
        _salesCgst,
        _salesSgst,
        _salesTotal,
        _salesPhone,
        _salesGstin,
      ]);
      await _loadAll();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to create invoice: $error')),
        );
      }
    }
  }

  Future<void> _createPurchase() async {
    final subtotal = _controllerNumber(_purchaseSubtotal);
    final cgst = _controllerNumber(_purchaseCgst);
    final sgst = _controllerNumber(_purchaseSgst);
    final total = _purchaseTotal.text.trim().isEmpty
        ? subtotal + cgst + sgst
        : _controllerNumber(_purchaseTotal);
    if (_purchaseBill.text.trim().isEmpty ||
        _vendor.text.trim().isEmpty ||
        total <= 0) {
      return;
    }

    try {
      await ref.read(apiClientProvider).post(
        '/accounting/purchase-invoices',
        {
          'bill_number': _purchaseBill.text.trim(),
          'vendor_name': _vendor.text.trim(),
          'vendor_gstin': _vendorGstin.text.trim().isEmpty
              ? null
              : _vendorGstin.text.trim().toUpperCase(),
          'subtotal': subtotal,
          'cgst': cgst,
          'sgst': sgst,
          'igst': 0,
          'total': total,
          'payment_status': 'unpaid',
        },
      );
      _clear([
        _purchaseBill,
        _vendor,
        _vendorGstin,
        _purchaseSubtotal,
        _purchaseCgst,
        _purchaseSgst,
        _purchaseTotal,
      ]);
      await _loadAll();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to record purchase: $error')),
        );
      }
    }
  }

  Future<void> _updatePurchasePayment(int id, String status) async {
    try {
      await ref.read(apiClientProvider).patch(
        '/accounting/purchase-invoices/$id/payment',
        {'payment_status': status},
      );
      await _loadAll();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to update bill: $error')),
        );
      }
    }
  }

  Future<void> _createExpense() async {
    final amount = _controllerNumber(_expenseAmount);
    if (_expenseCategory.text.trim().isEmpty ||
        _expenseDescription.text.trim().isEmpty ||
        amount <= 0) {
      return;
    }

    try {
      await ref.read(apiClientProvider).post(
        '/accounting/expenses',
        {
          'category': _expenseCategory.text.trim(),
          'description': _expenseDescription.text.trim(),
          'amount': amount,
          'gst_amount': _controllerNumber(_expenseGst),
          'payment_mode': 'bank',
        },
      );
      _clear([
        _expenseCategory,
        _expenseDescription,
        _expenseAmount,
        _expenseGst,
      ]);
      await _loadAll();
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Unable to record expense: $error')),
        );
      }
    }
  }

  void _clear(List<TextEditingController> controllers) {
    for (final controller in controllers) {
      controller.clear();
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    double width = 190,
    bool numeric = true,
  }) {
    return SizedBox(
      width: width,
      child: TextField(
        controller: controller,
        keyboardType: numeric
            ? const TextInputType.numberWithOptions(decimal: true)
            : TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
          isDense: true,
        ),
      ),
    );
  }

  Widget _summaryCard(String title, dynamic value, IconData icon) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              CircleAvatar(child: Icon(icon)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: const TextStyle(color: Colors.grey)),
                    const SizedBox(height: 5),
                    Text(
                      _money(value),
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _section(String title, String subtitle, Widget child) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            Text(subtitle, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }

  Widget _overviewTab() {
    final salesTotal = sales.fold<double>(0, (sum, item) => sum + _number(item['total']));
    final purchaseTotal = purchases.fold<double>(0, (sum, item) => sum + _number(item['total']));
    final expenseTotal = expenses.fold<double>(0, (sum, item) => sum + _number(item['amount']));
    final inputGst = _number(gst['input_gst']);
    final outputGst = _number(gst['output_gst']);

    return ListView(
      padding: const EdgeInsets.only(bottom: 30),
      children: [
        Row(
          children: [
            _summaryCard('Sales', salesTotal, Icons.point_of_sale),
            const SizedBox(width: 10),
            _summaryCard('Purchases', purchaseTotal, Icons.shopping_cart),
            const SizedBox(width: 10),
            _summaryCard('Expenses', expenseTotal, Icons.money_off),
          ],
        ),
        const SizedBox(height: 14),
        _section(
          'GST position',
          'Current accounting data available for return preparation',
          Row(
            children: [
              Expanded(child: _metric('Output GST', _money(outputGst))),
              Expanded(child: _metric('Input GST', _money(inputGst))),
              Expanded(child: _metric('Net GST', _money(outputGst - inputGst))),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _section(
          'Quick actions',
          'Keep bookkeeping inside SpiceOS',
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              FilledButton.icon(
                onPressed: () => _tabs.animateTo(1),
                icon: const Icon(Icons.add),
                label: const Text('New Sales Invoice'),
              ),
              OutlinedButton.icon(
                onPressed: () => _tabs.animateTo(2),
                icon: const Icon(Icons.add_business),
                label: const Text('Record Kitchen Purchase'),
              ),
              OutlinedButton.icon(
                onPressed: () => _tabs.animateTo(3),
                icon: const Icon(Icons.receipt_long),
                label: const Text('Record Expense'),
              ),
              OutlinedButton.icon(
                onPressed: () => _tabs.animateTo(5),
                icon: const Icon(Icons.account_balance),
                label: const Text('GST Profile'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _metric(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _salesTab() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 30),
      children: [
        _section(
          'Create sales invoice',
          'GST-ready invoice for dine-in, takeaway, delivery or walk-in sales',
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _field('Customer', _salesCustomer, numeric: false, width: 240),
              _field('Phone', _salesPhone, numeric: false, width: 180),
              _field('Customer GSTIN', _salesGstin, numeric: false, width: 210),
              _field('Subtotal', _salesSubtotal),
              _field('CGST', _salesCgst),
              _field('SGST', _salesSgst),
              _field('Total', _salesTotal),
              FilledButton.icon(
                onPressed: _createSale,
                icon: const Icon(Icons.receipt_long),
                label: const Text('Save Invoice'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _invoiceList(sales, purchase: false),
      ],
    );
  }

  Widget _purchaseTab() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 30),
      children: [
        _section(
          'Record kitchen purchase',
          'Track grocery, packaging, ingredients and supplier bills with GST',
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _field('Bill number', _purchaseBill, numeric: false, width: 170),
              _field('Supplier', _vendor, numeric: false, width: 220),
              _field('Supplier GSTIN', _vendorGstin, numeric: false, width: 210),
              _field('Subtotal', _purchaseSubtotal),
              _field('CGST', _purchaseCgst),
              _field('SGST', _purchaseSgst),
              _field('Total', _purchaseTotal),
              FilledButton.icon(
                onPressed: _createPurchase,
                icon: const Icon(Icons.save),
                label: const Text('Save Purchase'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _invoiceList(purchases, purchase: true),
      ],
    );
  }

  Widget _invoiceList(List<dynamic> rows, {required bool purchase}) {
    if (rows.isEmpty) {
      return _section(
        purchase ? 'Purchase register' : 'Sales register',
        'No records yet',
        const Padding(
          padding: EdgeInsets.all(18),
          child: Text('Records created in SpiceOS will appear here.'),
        ),
      );
    }
    return Card(
      child: Column(
        children: rows.take(100).map((item) {
          final id = _number(item['id']).toInt();
          final amount = item['total'] ?? item['amount'];
          final name = purchase
              ? item['vendor_name']?.toString() ?? 'Supplier'
              : item['customer_name']?.toString() ?? 'Customer';
          final number = purchase
              ? item['bill_number']?.toString() ?? '#$id'
              : item['invoice_number']?.toString() ?? '#$id';
          final status = item['payment_status']?.toString() ?? 'paid';
          return ListTile(
            leading: CircleAvatar(
              child: Icon(purchase ? Icons.shopping_bag : Icons.receipt_long),
            ),
            title: Text(name, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('$number • ${_date(item['created_at'] ?? item['invoice_date'])} • $status'),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_money(amount), style: const TextStyle(fontWeight: FontWeight.w800)),
                if (purchase) ...[
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    onSelected: (value) => _updatePurchasePayment(id, value),
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'paid', child: Text('Mark paid')),
                      PopupMenuItem(value: 'unpaid', child: Text('Mark unpaid')),
                      PopupMenuItem(value: 'partial', child: Text('Mark partial')),
                    ],
                  ),
                ],
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _expenseTab() {
    return ListView(
      padding: const EdgeInsets.only(bottom: 30),
      children: [
        _section(
          'Record expense',
          'Capture rent, utilities, delivery, packaging and other operating expenses',
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _field('Category', _expenseCategory, numeric: false, width: 190),
              _field('Description', _expenseDescription, numeric: false, width: 280),
              _field('Amount', _expenseAmount),
              _field('GST amount', _expenseGst),
              FilledButton.icon(
                onPressed: _createExpense,
                icon: const Icon(Icons.save),
                label: const Text('Save Expense'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        Card(
          child: Column(
            children: expenses.take(100).map((item) {
              return ListTile(
                leading: const CircleAvatar(child: Icon(Icons.receipt_long)),
                title: Text(item['description']?.toString() ?? 'Expense'),
                subtitle: Text(item['category']?.toString() ?? 'Other'),
                trailing: Text(
                  _money(item['amount']),
                  style: const TextStyle(fontWeight: FontWeight.w800),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _partiesTab() {
    final customers = <String>{};
    final vendors = <String>{};
    for (final item in sales) {
      final name = item['customer_name']?.toString();
      if (name != null && name.isNotEmpty) customers.add(name);
    }
    for (final item in purchases) {
      final name = item['vendor_name']?.toString();
      if (name != null && name.isNotEmpty) vendors.add(name);
    }
    return ListView(
      padding: const EdgeInsets.only(bottom: 30),
      children: [
        _section(
          'Customers',
          '${customers.length} customer accounts from sales invoices',
          Column(
            children: customers.isEmpty
                ? [const ListTile(title: Text('No customers recorded yet'))]
                : customers.map((name) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(name),
                    trailing: const Icon(Icons.chevron_right),
                  )).toList(),
          ),
        ),
        const SizedBox(height: 14),
        _section(
          'Suppliers',
          '${vendors.length} suppliers from purchase bills',
          Column(
            children: vendors.isEmpty
                ? [const ListTile(title: Text('No suppliers recorded yet'))]
                : vendors.map((name) => ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.store)),
                    title: Text(name),
                    trailing: const Icon(Icons.chevron_right),
                  )).toList(),
          ),
        ),
      ],
    );
  }

  Widget _gstTab() {
    final output = _number(gst['output_gst']);
    final input = _number(gst['input_gst']);
    return ListView(
      padding: const EdgeInsets.only(bottom: 30),
      children: [
        _section(
          'Business & GST profile',
          'Keep the legal identity used for invoices and GST records in one place',
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              _field('Legal name', _legalName, numeric: false, width: 300),
              _field('Trade name', _tradeName, numeric: false, width: 240),
              _field('GSTIN', _gstin, numeric: false, width: 210),
              _field('PAN', _pan, numeric: false, width: 180),
              _field('Phone', _phone, numeric: false, width: 180),
              _field('Email', _email, numeric: false, width: 260),
              _field('Address', _address, numeric: false, width: 420),
              _field('Pincode', _pincode, numeric: false, width: 150),
              DropdownButton<String>(
                value: _businessType,
                items: const [
                  DropdownMenuItem(value: 'Proprietorship', child: Text('Proprietorship')),
                  DropdownMenuItem(value: 'Partnership', child: Text('Partnership')),
                  DropdownMenuItem(value: 'LLP', child: Text('LLP')),
                  DropdownMenuItem(value: 'Private Limited', child: Text('Private Limited')),
                ],
                onChanged: (value) => setState(() => _businessType = value ?? _businessType),
              ),
              DropdownButton<String>(
                value: _state,
                items: const [
                  DropdownMenuItem(value: 'Bihar', child: Text('Bihar')),
                  DropdownMenuItem(value: 'Jharkhand', child: Text('Jharkhand')),
                  DropdownMenuItem(value: 'West Bengal', child: Text('West Bengal')),
                  DropdownMenuItem(value: 'Uttar Pradesh', child: Text('Uttar Pradesh')),
                ],
                onChanged: (value) => setState(() => _state = value ?? _state),
              ),
              DropdownButton<String>(
                value: _filingFrequency,
                items: const [
                  DropdownMenuItem(value: 'Monthly', child: Text('Monthly filing')),
                  DropdownMenuItem(value: 'Quarterly', child: Text('Quarterly filing')),
                ],
                onChanged: (value) => setState(() => _filingFrequency = value ?? _filingFrequency),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Checkbox(
                    value: _composition,
                    onChanged: (value) => setState(() => _composition = value ?? false),
                  ),
                  const Text('Composition scheme'),
                ],
              ),
              FilledButton.icon(
                onPressed: _saveProfile,
                icon: const Icon(Icons.save),
                label: const Text('Save GST Profile'),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _section(
          'GST summary',
          'Use these figures when preparing the relevant return period',
          Row(
            children: [
              Expanded(child: _metric('Output GST', _money(output))),
              Expanded(child: _metric('Input GST', _money(input))),
              Expanded(child: _metric('Estimated net', _money(output - input))),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reportsTab() {
    final salesTotal = sales.fold<double>(0, (sum, item) => sum + _number(item['total']));
    final purchaseTotal = purchases.fold<double>(0, (sum, item) => sum + _number(item['total']));
    final expenseTotal = expenses.fold<double>(0, (sum, item) => sum + _number(item['amount']));
    return ListView(
      padding: const EdgeInsets.only(bottom: 30),
      children: [
        _section(
          'Reports',
          'Management and compliance reports from your bookkeeping data',
          Column(
            children: [
              _reportRow('Sales Register', '${sales.length} invoices • ${_money(salesTotal)}', Icons.point_of_sale),
              _reportRow('Purchase Register', '${purchases.length} bills • ${_money(purchaseTotal)}', Icons.shopping_cart),
              _reportRow('Expense Report', '${expenses.length} entries • ${_money(expenseTotal)}', Icons.receipt_long),
              _reportRow('Customer Ledger', 'Customer-wise sales totals', Icons.people_outline),
              _reportRow('Supplier Ledger', 'Supplier-wise purchases and dues', Icons.storefront_outlined),
              _reportRow('GST Summary', 'Output GST, input GST and estimated net', Icons.account_balance),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _section(
          'Control centre',
          'Important bookkeeping controls',
          Column(
            children: [
              _statusRow('Invoice numbering', 'Automatic invoice sequence', true),
              _statusRow('Duplicate supplier bills', 'Bill number + supplier review', true),
              _statusRow('Branch isolation', 'Records scoped to restaurant', true),
              _statusRow('GST filing', 'Review and submit through authorised workflow', false),
            ],
          ),
        ),
      ],
    );
  }

  Widget _reportRow(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: CircleAvatar(child: Icon(icon)),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
    );
  }

  Widget _statusRow(String title, String subtitle, bool active) {
    return ListTile(
      leading: Icon(active ? Icons.check_circle : Icons.info_outline),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text(subtitle),
      trailing: Text(active ? 'ON' : 'REVIEW'),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: const [
                    Text(
                      'Accounting & GST',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Invoices, purchases, expenses, parties, GST and reports in one place.',
                    ),
                  ],
                ),
              ),
              if (loading)
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(),
                ),
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => _tabs.animateTo(1),
                icon: const Icon(Icons.add),
                label: const Text('New Invoice'),
              ),
              const SizedBox(width: 8),
              IconButton(onPressed: _loadAll, icon: const Icon(Icons.refresh)),
            ],
          ),
          const SizedBox(height: 18),
          TabBar(
            controller: _tabs,
            isScrollable: true,
            tabs: const [
              Tab(icon: Icon(Icons.dashboard_outlined), text: 'Overview'),
              Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Sales'),
              Tab(icon: Icon(Icons.shopping_cart_outlined), text: 'Purchases'),
              Tab(icon: Icon(Icons.money_off_outlined), text: 'Expenses'),
              Tab(icon: Icon(Icons.people_outline), text: 'Parties'),
              Tab(icon: Icon(Icons.account_balance_outlined), text: 'GST'),
              Tab(icon: Icon(Icons.bar_chart_outlined), text: 'Reports'),
            ],
          ),
          const SizedBox(height: 14),
          Expanded(
            child: TabBarView(
              controller: _tabs,
              children: [
                _overviewTab(),
                _salesTab(),
                _purchaseTab(),
                _expenseTab(),
                _partiesTab(),
                _gstTab(),
                _reportsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
