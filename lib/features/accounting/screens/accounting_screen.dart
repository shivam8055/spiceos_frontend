import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/app_shell.dart';

class AccountingScreen extends ConsumerStatefulWidget {
  const AccountingScreen({super.key});

  @override
  ConsumerState<AccountingScreen> createState() => _AccountingScreenState();
}

class _AccountingScreenState extends ConsumerState<AccountingScreen> with SingleTickerProviderStateMixin {
  late final TabController _tabs;
  bool loading = false;
  Map<String, dynamic>? gst;
  Map<String, dynamic>? profile;
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
    for (final c in [
      _salesSubtotal, _salesCgst, _salesSgst, _salesTotal, _salesCustomer, _salesPhone, _salesGstin,
      _purchaseBill, _vendor, _vendorGstin, _purchaseSubtotal, _purchaseCgst, _purchaseSgst, _purchaseTotal,
      _expenseCategory, _expenseDescription, _expenseAmount, _expenseGst,
      _legalName, _tradeName, _gstin, _pan, _address, _pincode, _phone, _email,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  double _num(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;
  double _value(dynamic value) => value is num ? value.toDouble() : double.tryParse('$value') ?? 0;
  String _money(dynamic value) => '₹${_value(value).toStringAsFixed(2)}';
  String _date(dynamic value) {
    final parsed = DateTime.tryParse('$value');
    if (parsed == null) return '-';
    return '${parsed.day.toString().padLeft(2, '0')}/${parsed.month.toString().padLeft(2, '0')}/${parsed.year}';
  }

  Future<void> _loadAll() async {
    setState(() => loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final responses = await Future.wait([
        api.get('/accounting/gst-summary'),
        api.get('/accounting/gst-profile'),
        api.get('/accounting/sales-invoices'),
        api.get('/accounting/purchase-invoices'),
        api.get('/accounting/expenses'),
      ]);
      if (!mounted) return;
      final p = Map<String, dynamic>.from(responses[1].data as Map);
      setState(() {
        gst = Map<String, dynamic>.from(responses[0].data as Map);
        profile = p;
        sales = List<dynamic>.from(responses[2].data as List);
        purchases = List<dynamic>.from(responses[3].data as List);
        expenses = List<dynamic>.from(responses[4].data as List);
      });
      _applyProfile(p);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Accounting load failed: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void _applyProfile(Map<String, dynamic> p) {
    _legalName.text = p['legal_name']?.toString() ?? '';
    _tradeName.text = p['trade_name']?.toString() ?? '';
    _gstin.text = p['gstin']?.toString() ?? '';
    _pan.text = p['pan']?.toString() ?? '';
    _address.text = p['address']?.toString() ?? '';
    _pincode.text = p['pincode']?.toString() ?? '';
    _phone.text = p['phone']?.toString() ?? '';
    _email.text = p['email']?.toString() ?? '';
    if (p['business_type'] != null) _businessType = p['business_type'].toString();
    if (p['state'] != null) _state = p['state'].toString();
    if (p['state_code'] != null) _stateCode = p['state_code'].toString();
    if (p['filing_frequency'] != null) _filingFrequency = p['filing_frequency'].toString();
    _composition = p['composition_scheme'] == true;
  }

  Future<void> _saveProfile() async {
    try {
      final saved = await ref.read(apiClientProvider).put('/accounting/gst-profile', {
        'legal_name': _legalName.text.trim(), 'trade_name': _tradeName.text.trim(),
        'gstin': _gstin.text.trim().isEmpty ? null : _gstin.text.trim().toUpperCase(),
        'pan': _pan.text.trim().isEmpty ? null : _pan.text.trim().toUpperCase(),
        'business_type': _businessType, 'state': _state, 'state_code': _stateCode,
        'address': _address.text.trim(), 'pincode': _pincode.text.trim(), 'phone': _phone.text.trim(),
        'email': _email.text.trim(), 'filing_frequency': _filingFrequency, 'composition_scheme': _composition,
      });
      if (!mounted) return;
      setState(() => profile = Map<String, dynamic>.from(saved.data as Map));
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('GST business profile saved')));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to save GST profile: $e')));
    }
  }

  Future<void> _createSale() async {
    final subtotal = _num(_salesSubtotal);
    final cgst = _num(_salesCgst);
    final sgst = _num(_salesSgst);
    final total = _salesTotal.text.trim().isEmpty ? subtotal + cgst + sgst : _num(_salesTotal);
    if (subtotal <= 0 || total <= 0) return;
    await ref.read(apiClientProvider).post('/accounting/sales-invoices', {
      'subtotal': subtotal, 'cgst': cgst, 'sgst': sgst, 'igst': 0, 'discount': 0, 'total': total,
      'payment_status': 'paid', 'customer_name': _salesCustomer.text.trim().isEmpty ? 'Walk-in Customer' : _salesCustomer.text.trim(),
      'customer_phone': _salesPhone.text.trim().isEmpty ? null : _salesPhone.text.trim(),
      'customer_gstin': _salesGstin.text.trim().isEmpty ? null : _salesGstin.text.trim().toUpperCase(),
    });
    _clear([_salesSubtotal, _salesCgst, _salesSgst, _salesTotal, _salesPhone, _salesGstin]);
    await _loadAll();
  }

  Future<void> _createPurchase() async {
    final subtotal = _num(_purchaseSubtotal);
    final cgst = _num(_purchaseCgst);
    final sgst = _num(_purchaseSgst);
    final total = _purchaseTotal.text.trim().isEmpty ? subtotal + cgst + sgst : _num(_purchaseTotal);
    if (_purchaseBill.text.trim().isEmpty || _vendor.text.trim().isEmpty || total <= 0) return;
    await ref.read(apiClientProvider).post('/accounting/purchase-invoices', {
      'bill_number': _purchaseBill.text.trim(), 'vendor_name': _vendor.text.trim(),
      'vendor_gstin': _vendorGstin.text.trim().isEmpty ? null : _vendorGstin.text.trim().toUpperCase(),
      'subtotal': subtotal, 'cgst': cgst, 'sgst': sgst, 'igst': 0, 'total': total, 'payment_status': 'unpaid',
    });
    _clear([_purchaseBill, _vendor, _vendorGstin, _purchaseSubtotal, _purchaseCgst, _purchaseSgst, _purchaseTotal]);
    await _loadAll();
  }

  Future<void> _updatePurchasePayment(int id, String status) async {
    try {
      await ref.read(apiClientProvider).patch('/accounting/purchase-invoices/$id/payment', {'payment_status': status});
      await _loadAll();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to update bill: $e')));
    }
  }

  Future<void> _createExpense() async {
    final amount = _num(_expenseAmount);
    if (_expenseCategory.text.trim().isEmpty || _expenseDescription.text.trim().isEmpty || amount <= 0) return;
    await ref.read(apiClientProvider).post('/accounting/expenses', {
      'category': _expenseCategory.text.trim(), 'description': _expenseDescription.text.trim(),
      'amount': amount, 'gst_amount': _num(_expenseGst), 'payment_mode': 'bank',
    });
    _clear([_expenseCategory, _expenseDescription, _expenseAmount, _expenseGst]);
    await _loadAll();
  }

  void _clear(List<TextEditingController> cs) { for (final c in cs) c.clear(); }
  void _go(int index) => _tabs.animateTo(index);

  Widget _field(String label, TextEditingController c, {double width = 190, bool numeric = true}) => SizedBox(
    width: width,
    child: TextField(
      controller: c,
      keyboardType: numeric ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
      decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true),
    ),
  );

  Widget _summary(String title, dynamic value, IconData icon, {String? subtitle}) => Expanded(
    child: Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          CircleAvatar(child: Icon(icon)), const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(title, style: const TextStyle(color: Colors.grey)), const SizedBox(height: 5),
            Text(_money(value), style: const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
            if (subtitle != null) Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ])),
        ]),
      ),
    ),
  );

  Widget _section(String title, String subtitle, Widget child) => Card(
    child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title, style: const TextStyle(fontSize: 19, fontWeight: FontWeight.w800)),
      const SizedBox(height: 4), Text(subtitle, style: const TextStyle(color: Colors.grey)),
      const SizedBox(height: 16), child,
    ])),
  );

  Widget _overviewTab() {
    final salesTotal = _value(gst?['total_sales']);
    final purchaseTotal = _value(gst?['total_purchases']);
    final expensesTotal = _value(gst?['total_expenses']);
    final output = _value(gst?['output_cgst']) + _value(gst?['output_sgst']) + _value(gst?['output_igst']);
    final input = _value(gst?['input_cgst']) + _value(gst?['input_sgst']) + _value(gst?['input_igst']);
    final outstanding = purchases.where((x) => x['payment_status'] != 'paid').fold<double>(0, (sum, x) => sum + _value(x['total']));
    final net = salesTotal - purchaseTotal - expensesTotal;

    return ListView(children: [
      Row(children: [
        _summary('Sales', salesTotal, Icons.point_of_sale_outlined, subtitle: '${sales.length} invoices'), const SizedBox(width: 12),
        _summary('Purchases', purchaseTotal, Icons.shopping_cart_checkout, subtitle: '${purchases.length} bills'), const SizedBox(width: 12),
        _summary('Expenses', expensesTotal, Icons.receipt_long_outlined, subtitle: '${expenses.length} entries'),
      ]),
      const SizedBox(height: 12),
      Row(children: [
        _summary('Estimated GST', output - input, Icons.account_balance_outlined, subtitle: 'Output ₹${output.toStringAsFixed(2)} − Input ₹${input.toStringAsFixed(2)}'), const SizedBox(width: 12),
        _summary('Vendor Due', outstanding, Icons.credit_card_outlined, subtitle: 'Unpaid / partial bills'), const SizedBox(width: 12),
        _summary('Operating Balance', net, Icons.insights_outlined, subtitle: 'Sales − purchases − expenses'),
      ]),
      const SizedBox(height: 16),
      _section('Quick actions', 'Common tasks for a restaurant owner', Wrap(spacing: 10, runSpacing: 10, children: [
        FilledButton.icon(onPressed: () => _go(1), icon: const Icon(Icons.add), label: const Text('New Sale Invoice')),
        FilledButton.tonalIcon(onPressed: () => _go(2), icon: const Icon(Icons.add_shopping_cart), label: const Text('Record Kitchen Purchase')),
        FilledButton.tonalIcon(onPressed: () => _go(3), icon: const Icon(Icons.money_off), label: const Text('Add Expense')),
        FilledButton.tonalIcon(onPressed: () => _go(5), icon: const Icon(Icons.receipt), label: const Text('GST / Returns')),
        FilledButton.tonalIcon(onPressed: () => _go(6), icon: const Icon(Icons.bar_chart), label: const Text('Reports')),
      ])),
      const SizedBox(height: 16),
      _section('GST health', 'Keep your books ready for monthly return preparation', Column(children: [
        _statusRow('GSTIN', profile?['gstin']?.toString().isNotEmpty == true ? profile!['gstin'].toString() : 'Not configured', profile?['gstin']?.toString().isNotEmpty == true),
        _statusRow('Business profile', profile?['legal_name']?.toString().isNotEmpty == true ? 'Configured' : 'Complete business details', profile?['legal_name']?.toString().isNotEmpty == true),
        _statusRow('Sales invoices', '${sales.length} recorded', true),
        _statusRow('Purchase bills', '${purchases.length} recorded', true),
        _statusRow('Return status', 'Books ready • filing remains a review step', false),
      ])),
    ]);
  }

  Widget _statusRow(String label, String value, bool ok) => ListTile(
    dense: true, contentPadding: EdgeInsets.zero,
    leading: Icon(ok ? Icons.check_circle : Icons.info_outline, color: ok ? Colors.green : Colors.orange),
    title: Text(label), trailing: Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
  );

  Widget _salesTab() => ListView(children: [
    _section('Create sales invoice', 'Record a GST-ready sale. Orders can also be invoiced from the Orders workflow.', Wrap(spacing: 12, runSpacing: 12, children: [
      _field('Customer', _salesCustomer, numeric: false, width: 230), _field('Phone', _salesPhone, width: 180), _field('Customer GSTIN', _salesGstin, numeric: false, width: 210),
      _field('Taxable amount', _salesSubtotal), _field('CGST', _salesCgst), _field('SGST', _salesSgst), _field('Total', _salesTotal),
      FilledButton.icon(onPressed: _createSale, icon: const Icon(Icons.save_outlined), label: const Text('Save Invoice')),
    ])),
    const SizedBox(height: 12),
    _section('Sales register', 'Latest invoices, payment status and GST amounts', Column(children: [
      if (sales.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('No sales invoices recorded yet.')),
      ...sales.map((x) => _invoiceTile(x)),
    ])),
  ]);

  Widget _invoiceTile(Map<dynamic, dynamic> x) => ListTile(
    contentPadding: const EdgeInsets.symmetric(vertical: 4),
    leading: const CircleAvatar(child: Icon(Icons.description_outlined)),
    title: Text('${x['invoice_number']} • ${x['customer_name'] ?? 'Walk-in Customer'}', style: const TextStyle(fontWeight: FontWeight.w700)),
    subtitle: Text('${_date(x['invoice_date'])} • GST ${_money(_value(x['cgst']) + _value(x['sgst']) + _value(x['igst']))}'),
    trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
      Text(_money(x['total']), style: const TextStyle(fontWeight: FontWeight.w800)),
      Text('${x['payment_status'] ?? 'pending'}', style: const TextStyle(fontSize: 12)),
    ]),
  );

  Widget _purchaseTab() => ListView(children: [
    _section('Record kitchen purchase', 'Keep supplier bills, GST input credit and payment status in one place.', Wrap(spacing: 12, runSpacing: 12, children: [
      _field('Bill number', _purchaseBill, numeric: false, width: 180), _field('Supplier', _vendor, numeric: false, width: 230), _field('Supplier GSTIN', _vendorGstin, numeric: false, width: 210),
      _field('Taxable amount', _purchaseSubtotal), _field('CGST', _purchaseCgst), _field('SGST', _purchaseSgst), _field('Total', _purchaseTotal),
      FilledButton.icon(onPressed: _createPurchase, icon: const Icon(Icons.save_outlined), label: const Text('Save Purchase Bill')),
    ])),
    const SizedBox(height: 12),
    _section('Purchase register', 'Track every bill purchased for the kitchen and its outstanding amount.', Column(children: [
      if (purchases.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('No purchase bills recorded yet.')),
      ...purchases.map((raw) {
        final x = Map<String, dynamic>.from(raw as Map);
        final status = x['payment_status']?.toString() ?? 'unpaid';
        return ListTile(
          contentPadding: const EdgeInsets.symmetric(vertical: 4), leading: const CircleAvatar(child: Icon(Icons.storefront_outlined)),
          title: Text('${x['bill_number']} • ${x['vendor_name']}', style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text('${_date(x['invoice_date'])} • GST ${_money(_value(x['cgst']) + _value(x['sgst']) + _value(x['igst']))}'),
          trailing: SizedBox(width: 150, child: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
            Text(_money(x['total']), style: const TextStyle(fontWeight: FontWeight.w800)),
            DropdownButton<String>(value: status, isDense: true, items: const [
              DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')), DropdownMenuItem(value: 'partial', child: Text('Partial')), DropdownMenuItem(value: 'paid', child: Text('Paid')),
            ], onChanged: (v) => v == null ? null : _updatePurchasePayment(x['id'] as int, v)),
          ])),
        );
      }),
    ])),
  ]);

  Widget _expenseTab() => ListView(children: [
    _section('Record expense', 'Capture rent, electricity, delivery, packaging, repairs and other operating costs.', Wrap(spacing: 12, runSpacing: 12, children: [
      _field('Category', _expenseCategory, numeric: false, width: 190), _field('Description', _expenseDescription, numeric: false, width: 260), _field('Amount', _expenseAmount), _field('GST amount', _expenseGst),
      FilledButton.icon(onPressed: _createExpense, icon: const Icon(Icons.save_outlined), label: const Text('Save Expense')),
    ])),
    const SizedBox(height: 12),
    _section('Expense register', 'All operating expenses in one searchable-style register.', Column(children: [
      if (expenses.isEmpty) const Padding(padding: EdgeInsets.all(24), child: Text('No expenses recorded yet.')),
      ...expenses.map((raw) { final x = Map<String, dynamic>.from(raw as Map); return ListTile(
        leading: const CircleAvatar(child: Icon(Icons.receipt_long_outlined)),
        title: Text('${x['category']} • ${x['description']}', style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${_date(x['expense_date'])} • ${x['payment_mode'] ?? 'cash'}'),
        trailing: Text(_money(x['amount']), style: const TextStyle(fontWeight: FontWeight.w800)),
      ); }),
    ])),
  ]);

  Widget _partiesTab() {
    final customers = <String, Map<String, dynamic>>{};
    for (final raw in sales) {
      final x = Map<String, dynamic>.from(raw as Map); final name = x['customer_name']?.toString() ?? 'Walk-in Customer';
      final e = customers.putIfAbsent(name, () => {'amount': 0.0, 'count': 0, 'gstin': x['customer_gstin']});
      e['amount'] = (e['amount'] as double) + _value(x['total']); e['count'] = (e['count'] as int) + 1;
    }
    final vendors = <String, Map<String, dynamic>>{};
    for (final raw in purchases) {
      final x = Map<String, dynamic>.from(raw as Map); final name = x['vendor_name']?.toString() ?? 'Unknown Supplier';
      final e = vendors.putIfAbsent(name, () => {'amount': 0.0, 'due': 0.0, 'count': 0, 'gstin': x['vendor_gstin']});
      e['amount'] = (e['amount'] as double) + _value(x['total']); e['count'] = (e['count'] as int) + 1;
      if (x['payment_status'] != 'paid') e['due'] = (e['due'] as double) + _value(x['total']);
    }
    return ListView(children: [
      _section('Customers', 'Customer ledger built automatically from sales invoices.', Column(children: [
        if (customers.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('Customers will appear after your first invoice.')),
        ...customers.entries.map((e) => ListTile(leading: const CircleAvatar(child: Icon(Icons.person_outline)), title: Text(e.key), subtitle: Text('${e.value['count']} invoice(s)${e.value['gstin'] == null ? '' : ' • GSTIN ${e.value['gstin']}'}'), trailing: Text(_money(e.value['amount']), style: const TextStyle(fontWeight: FontWeight.w800)))),
      ])),
      const SizedBox(height: 12),
      _section('Suppliers / vendors', 'Supplier balances from kitchen purchase bills.', Column(children: [
        if (vendors.isEmpty) const Padding(padding: EdgeInsets.all(20), child: Text('Suppliers will appear after your first purchase bill.')),
        ...vendors.entries.map((e) => ListTile(leading: const CircleAvatar(child: Icon(Icons.storefront_outlined)), title: Text(e.key), subtitle: Text('${e.value['count']} bill(s) • Total ${_money(e.value['amount'])}'), trailing: Text('Due ${_money(e.value['due'])}', style: const TextStyle(fontWeight: FontWeight.w800)))),
      ])),
    ]);
  }

  Widget _gstTab() {
    final output = _value(gst?['output_cgst']) + _value(gst?['output_sgst']) + _value(gst?['output_igst']);
    final input = _value(gst?['input_cgst']) + _value(gst?['input_sgst']) + _value(gst?['input_igst']);
    final net = output - input;
    return ListView(children: [
      Row(children: [
        _summary('Output GST', output, Icons.arrow_upward, subtitle: 'Collected on sales'), const SizedBox(width: 12),
        _summary('Input GST', input, Icons.arrow_downward, subtitle: 'Eligible purchase-side records'), const SizedBox(width: 12),
        _summary('Estimated Net GST', net, Icons.account_balance, subtitle: 'Bookkeeping estimate only'),
      ]),
      const SizedBox(height: 12),
      _section('GST return centre', 'Vyapar-style return preparation, without claiming that SpiceOS has filed the return.', Column(children: [
        _returnCard('GSTR-1', 'Outward supplies / sales invoices', '${sales.length} invoices • Taxable ${_money(gst?['sales_taxable'])}', 'Prepare sales data', Icons.upload_file),
        _returnCard('GSTR-3B', 'Summary of outward tax and eligible input tax', 'Output ${_money(output)} • Input ${_money(input)} • Net ${_money(net)}', 'Review 3B summary', Icons.summarize_outlined),
        _returnCard('Purchase / ITC register', 'Supplier bills and GST input records', '${purchases.length} purchase bills • Taxable ${_money(gst?['purchase_taxable'])}', 'Review purchase register', Icons.shopping_bag_outlined),
      ])),
      const SizedBox(height: 12),
      _section('GST business profile', 'This information is used on future invoices and GST reports.', Column(children: [
        Wrap(spacing: 12, runSpacing: 12, children: [
          _field('Legal name', _legalName, numeric: false, width: 260), _field('Trade name', _tradeName, numeric: false, width: 260), _field('GSTIN', _gstin, numeric: false, width: 210), _field('PAN', _pan, numeric: false, width: 170),
          _dropdown('Business type', _businessType, ['Proprietorship', 'Partnership', 'LLP', 'Private Limited', 'Other'], (v) => setState(() => _businessType = v!)),
          _dropdown('State', _state, ['Bihar', 'Jharkhand', 'Uttar Pradesh', 'West Bengal', 'Delhi', 'Maharashtra', 'Other'], (v) => setState(() { _state = v!; _stateCode = _state == 'Bihar' ? '10' : _stateCode; })),
          _field('State code', TextEditingController(text: _stateCode), numeric: false, width: 120), _field('Pincode', _pincode, width: 140), _field('Phone', _phone, width: 180), _field('Email', _email, numeric: false, width: 230),
        ]),
        const SizedBox(height: 12), TextField(controller: _address, maxLines: 2, decoration: const InputDecoration(labelText: 'Business address', border: OutlineInputBorder())),
        SwitchListTile(contentPadding: EdgeInsets.zero, title: const Text('Composition scheme'), subtitle: const Text('Enable only if the business is actually registered under composition'), value: _composition, onChanged: (v) => setState(() => _composition = v)),
        Row(children: [
          _dropdown('Filing frequency', _filingFrequency, ['Monthly', 'Quarterly'], (v) => setState(() => _filingFrequency = v!)),
          const Spacer(), FilledButton.icon(onPressed: _saveProfile, icon: const Icon(Icons.save_outlined), label: const Text('Save GST Profile')),
        ]),
      ])),
    ]);
  }

  Widget _dropdown(String label, String value, List<String> items, ValueChanged<String?> onChanged) => SizedBox(width: 190, child: DropdownButtonFormField<String>(value: items.contains(value) ? value : items.first, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder(), isDense: true), items: items.map((x) => DropdownMenuItem(value: x, child: Text(x))).toList(), onChanged: onChanged));

  Widget _returnCard(String title, String subtitle, String detail, String action, IconData icon) => Card(
    margin: const EdgeInsets.only(bottom: 10), color: Theme.of(context).colorScheme.surfaceContainerHighest,
    child: ListTile(leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w800)), subtitle: Text('$subtitle\n$detail'), isThreeLine: true, trailing: FilledButton.tonal(onPressed: () {}, child: Text(action))),
  );

  Widget _reportsTab() {
    final salesTotal = _value(gst?['total_sales']);
    final purchaseTotal = _value(gst?['total_purchases']);
    final expenseTotal = _value(gst?['total_expenses']);
    final net = salesTotal - purchaseTotal - expenseTotal;
    return ListView(children: [
      Row(children: [
        _summary('Revenue', salesTotal, Icons.trending_up), const SizedBox(width: 12), _summary('Purchases', purchaseTotal, Icons.shopping_basket_outlined), const SizedBox(width: 12), _summary('Expenses', expenseTotal, Icons.money_off), const SizedBox(width: 12), _summary('Net', net, Icons.assessment_outlined),
      ]),
      const SizedBox(height: 12),
      _section('Business reports', 'Owner-friendly reports similar to an accounting app, generated from your live records.', Column(children: [
        _reportRow('Sales Register', '${sales.length} invoices • ${_money(salesTotal)}', Icons.point_of_sale, () => _go(1)),
        _reportRow('Purchase Register', '${purchases.length} bills • ${_money(purchaseTotal)}', Icons.shopping_cart, () => _go(2)),
        _reportRow('Expense Report', '${expenses.length} entries • ${_money(expenseTotal)}', Icons.receipt_long, () => _go(3)),
        _reportRow('Customer Ledger', 'Customer-wise sales totals', Icons.people_outline, () => _go(4)),
        _reportRow('Supplier Ledger', 'Supplier-wise purchases and dues', Icons.storefront_outlined, () => _go(4)),
        _reportRow('GST Summary', 'Output GST, input GST and estimated net', Icons.account_balance, () => _go(5)),
      ])),
      const SizedBox(height: 12),
      _section('Control centre', 'Important bookkeeping controls', Column(children: [
        _statusRow('Invoice numbering', 'Automatic monthly INV-YYYYMM sequence', true),
        _statusRow('Duplicate supplier bills', 'Blocked by bill number + supplier', true),
        _statusRow('Branch isolation', 'Records scoped to restaurant', true),
        _statusRow('GST filing', 'Review / submit through authorised filing workflow', false),
      ])),
    ]);
  }

  Widget _reportRow(String title, String subtitle, IconData icon, VoidCallback onTap) => ListTile(
    onTap: onTap, leading: CircleAvatar(child: Icon(icon)), title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text(subtitle), trailing: const Icon(Icons.chevron_right),
  );

  @override
  Widget build(BuildContext context) => AppShell(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [
      const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text('Accounting & GST', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)), SizedBox(height: 5), Text('Complete restaurant bookkeeping: invoices, purchases, expenses, parties, GST and reports.')]),
      if (loading) const SizedBox(width: 22, height: 22, child: CircularProgressIndicator()),
      const SizedBox(width: 12), FilledButton.icon(onPressed: () => _go(1), icon: const Icon(Icons.add), label: const Text('New Invoice')), const SizedBox(width: 8), IconButton(onPressed: _loadAll, icon: const Icon(Icons.refresh)),
    ]),
    const SizedBox(height: 20),
    TabBar(isScrollable: true, controller: _tabs, tabs: const [
      Tab(icon: Icon(Icons.dashboard_outlined), text: 'Overview'), Tab(icon: Icon(Icons.receipt_long_outlined), text: 'Sales'), Tab(icon: Icon(Icons.shopping_cart_outlined), text: 'Purchases'),
      Tab(icon: Icon(Icons.money_off_outlined), text: 'Expenses'), Tab(icon: Icon(Icons.people_outline), text: 'Parties'), Tab(icon: Icon(Icons.account_balance_outlined), text: 'GST'), Tab(icon: Icon(Icons.bar_chart_outlined), text: 'Reports'),
    ]),
    const SizedBox(height: 16),
    Expanded(child: TabBarView(controller: _tabs, children: [_overviewTab(), _salesTab(), _purchaseTab(), _expenseTab(), _partiesTab(), _gstTab(), _reportsTab()])),
  ]));
}
