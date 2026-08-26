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
  final _salesSubtotal = TextEditingController();
  final _salesCgst = TextEditingController();
  final _salesSgst = TextEditingController();
  final _salesTotal = TextEditingController();
  final _purchaseBill = TextEditingController();
  final _vendor = TextEditingController();
  final _purchaseSubtotal = TextEditingController();
  final _purchaseCgst = TextEditingController();
  final _purchaseSgst = TextEditingController();
  final _purchaseTotal = TextEditingController();
  final _expenseCategory = TextEditingController();
  final _expenseDescription = TextEditingController();
  final _expenseAmount = TextEditingController();
  bool loading = false;
  Map<String, dynamic>? gst;
  List<dynamic> sales = [];
  List<dynamic> purchases = [];
  List<dynamic> expenses = [];

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
    _loadAll();
  }

  @override
  void dispose() {
    _tabs.dispose();
    for (final c in [_salesSubtotal, _salesCgst, _salesSgst, _salesTotal, _purchaseBill, _vendor, _purchaseSubtotal, _purchaseCgst, _purchaseSgst, _purchaseTotal, _expenseCategory, _expenseDescription, _expenseAmount]) { c.dispose(); }
    super.dispose();
  }

  Future<void> _loadAll() async {
    setState(() => loading = true);
    try {
      final api = ref.read(apiClientProvider);
      final responses = await Future.wait([
        api.get('/accounting/gst-summary'),
        api.get('/accounting/sales-invoices'),
        api.get('/accounting/purchase-invoices'),
        api.get('/accounting/expenses'),
      ]);
      if (!mounted) return;
      setState(() {
        gst = Map<String, dynamic>.from(responses[0].data as Map);
        sales = List<dynamic>.from(responses[1].data as List);
        purchases = List<dynamic>.from(responses[2].data as List);
        expenses = List<dynamic>.from(responses[3].data as List);
      });
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Accounting load failed: $e')));
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  double _num(TextEditingController c) => double.tryParse(c.text.trim()) ?? 0;

  Future<void> _createSale() async {
    final subtotal = _num(_salesSubtotal), cgst = _num(_salesCgst), sgst = _num(_salesSgst);
    final total = _salesTotal.text.trim().isEmpty ? subtotal + cgst + sgst : _num(_salesTotal);
    if (subtotal <= 0 || total <= 0) return;
    await ref.read(apiClientProvider).post('/accounting/sales-invoices', {
      'subtotal': subtotal, 'cgst': cgst, 'sgst': sgst, 'igst': 0, 'discount': 0, 'total': total, 'payment_status': 'paid', 'customer_name': 'Walk-in Customer'
    });
    _clear([_salesSubtotal, _salesCgst, _salesSgst, _salesTotal]);
    await _loadAll();
  }

  Future<void> _createPurchase() async {
    final subtotal = _num(_purchaseSubtotal), cgst = _num(_purchaseCgst), sgst = _num(_purchaseSgst);
    final total = _purchaseTotal.text.trim().isEmpty ? subtotal + cgst + sgst : _num(_purchaseTotal);
    if (_purchaseBill.text.trim().isEmpty || _vendor.text.trim().isEmpty || total <= 0) return;
    await ref.read(apiClientProvider).post('/accounting/purchase-invoices', {
      'bill_number': _purchaseBill.text.trim(), 'vendor_name': _vendor.text.trim(), 'subtotal': subtotal, 'cgst': cgst, 'sgst': sgst, 'igst': 0, 'total': total, 'payment_status': 'unpaid'
    });
    _clear([_purchaseBill, _vendor, _purchaseSubtotal, _purchaseCgst, _purchaseSgst, _purchaseTotal]);
    await _loadAll();
  }

  Future<void> _updatePurchasePayment(int invoiceId, String status) async {
    try {
      await ref.read(apiClientProvider).patch('/accounting/purchase-invoices/$invoiceId/payment', {'payment_status': status});
      await _loadAll();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Unable to update bill payment: $e')));
    }
  }

  Future<void> _createExpense() async {
    final amount = _num(_expenseAmount);
    if (_expenseCategory.text.trim().isEmpty || _expenseDescription.text.trim().isEmpty || amount <= 0) return;
    await ref.read(apiClientProvider).post('/accounting/expenses', {
      'category': _expenseCategory.text.trim(), 'description': _expenseDescription.text.trim(), 'amount': amount, 'gst_amount': 0, 'payment_mode': 'bank'
    });
    _clear([_expenseCategory, _expenseDescription, _expenseAmount]);
    await _loadAll();
  }

  void _clear(List<TextEditingController> cs) { for (final c in cs) c.clear(); }

  Widget _field(String label, TextEditingController c, {String? hint}) => SizedBox(width: 180, child: TextField(controller: c, keyboardType: const TextInputType.numberWithOptions(decimal: true), decoration: InputDecoration(labelText: label, hintText: hint, border: const OutlineInputBorder())));
  Widget _textField(String label, TextEditingController c) => SizedBox(width: 220, child: TextField(controller: c, decoration: InputDecoration(labelText: label, border: const OutlineInputBorder())));

  Widget _summaryCard(String title, dynamic value) => Expanded(child: Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(title, style: const TextStyle(color: Colors.grey)), const SizedBox(height: 8), Text('₹${(double.tryParse('$value') ?? 0).toStringAsFixed(2)}', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold))]))));

  Widget _gstTab() {
    final data = gst ?? {};
    return ListView(children: [
      Row(children: [_summaryCard('Sales', data['total_sales']), const SizedBox(width: 12), _summaryCard('Purchases', data['total_purchases']), const SizedBox(width: 12), _summaryCard('Expenses', data['total_expenses'])]),
      const SizedBox(height: 16),
      Card(child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('GST position', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)), const SizedBox(height: 16),
        Text('Output CGST: ₹${data['output_cgst'] ?? 0}'), Text('Input CGST: ₹${data['input_cgst'] ?? 0}'), Text('Estimated net CGST: ₹${data['estimated_net_cgst'] ?? 0}'), const Divider(),
        Text('Output SGST: ₹${data['output_sgst'] ?? 0}'), Text('Input SGST: ₹${data['input_sgst'] ?? 0}'), Text('Estimated net SGST: ₹${data['estimated_net_sgst'] ?? 0}'), const Divider(),
        Text('Output IGST: ₹${data['output_igst'] ?? 0}'), Text('Input IGST: ₹${data['input_igst'] ?? 0}'), Text('Estimated net IGST: ₹${data['estimated_net_igst'] ?? 0}'),
        const SizedBox(height: 12), const Text('This is a bookkeeping estimate; final GSTR filing should be reviewed by your tax professional.', style: TextStyle(color: Colors.grey)),
      ]))),
    ]);
  }

  Widget _salesTab() => ListView(children: [Card(child: Padding(padding: const EdgeInsets.all(16), child: Wrap(spacing: 12, runSpacing: 12, children: [_field('Subtotal', _salesSubtotal), _field('CGST', _salesCgst), _field('SGST', _salesSgst), _field('Total', _salesTotal), FilledButton(onPressed: _createSale, child: const Text('Create Sales Invoice'))]))), const SizedBox(height: 12), ...sales.map((x) => ListTile(title: Text('${x['invoice_number']} • ${x['customer_name']}'), subtitle: Text('₹${x['total']} • GST ₹${(x['cgst'] ?? 0) + (x['sgst'] ?? 0) + (x['igst'] ?? 0)}'), trailing: Text(x['payment_status'] ?? 'pending')))]);

  Widget _purchaseTab() => ListView(children: [
    Card(child: Padding(padding: const EdgeInsets.all(16), child: Wrap(spacing: 12, runSpacing: 12, children: [_textField('Bill number', _purchaseBill), _textField('Vendor', _vendor), _field('Subtotal', _purchaseSubtotal), _field('CGST', _purchaseCgst), _field('SGST', _purchaseSgst), _field('Total', _purchaseTotal), FilledButton(onPressed: _createPurchase, child: const Text('Record Kitchen Purchase'))]))),
    const SizedBox(height: 12),
    ...purchases.map((x) {
      final status = x['payment_status']?.toString() ?? 'unpaid';
      final id = x['id'] as int;
      return ListTile(
        title: Text('${x['bill_number']} • ${x['vendor_name']}'),
        subtitle: Text('₹${x['total']} • GST ₹${(x['cgst'] ?? 0) + (x['sgst'] ?? 0) + (x['igst'] ?? 0)}'),
        trailing: DropdownButton<String>(
          value: status,
          items: const [
            DropdownMenuItem(value: 'unpaid', child: Text('Unpaid')),
            DropdownMenuItem(value: 'partial', child: Text('Partial')),
            DropdownMenuItem(value: 'paid', child: Text('Paid')),
          ],
          onChanged: (value) => value == null ? null : _updatePurchasePayment(id, value),
        ),
      );
    }),
  ]);

  Widget _vendorsTab() {
    final grouped = <String, Map<String, dynamic>>{};
    for (final raw in purchases) {
      final x = Map<String, dynamic>.from(raw as Map);
      final vendor = x['vendor_name']?.toString() ?? 'Unknown Vendor';
      final total = (x['total'] as num?)?.toDouble() ?? 0;
      final status = x['payment_status']?.toString() ?? 'unpaid';
      final entry = grouped.putIfAbsent(vendor, () => {'total': 0.0, 'outstanding': 0.0, 'bills': 0});
      entry['total'] = (entry['total'] as double) + total;
      entry['bills'] = (entry['bills'] as int) + 1;
      if (status != 'paid') entry['outstanding'] = (entry['outstanding'] as double) + total;
    }
    final vendors = grouped.entries.toList()..sort((a, b) => (b.value['outstanding'] as double).compareTo(a.value['outstanding'] as double));
    final outstanding = vendors.fold<double>(0, (sum, item) => sum + (item.value['outstanding'] as double));
    return ListView(children: [
      Row(children: [
        _summaryCard('Vendor Bills', purchases.length),
        const SizedBox(width: 12),
        _summaryCard('Outstanding', outstanding),
      ]),
      const SizedBox(height: 16),
      if (vendors.isEmpty)
        const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: Text('Vendor ledger will appear after your first kitchen purchase.'))))
      else
        ...vendors.map((entry) {
          final data = entry.value;
          return Card(child: ListTile(
            leading: const CircleAvatar(child: Icon(Icons.storefront_outlined)),
            title: Text(entry.key, style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text('${data['bills']} bill(s) • Total purchases ₹${(data['total'] as double).toStringAsFixed(2)}'),
            trailing: Column(mainAxisAlignment: MainAxisAlignment.center, crossAxisAlignment: CrossAxisAlignment.end, children: [
              Text('Due ₹${(data['outstanding'] as double).toStringAsFixed(2)}', style: TextStyle(fontWeight: FontWeight.w700, color: data['outstanding'] as double > 0 ? Colors.orange.shade800 : Colors.green.shade700)),
              const Text('Outstanding', style: TextStyle(fontSize: 11)),
            ]),
          ));
        }),
    ]);
  }

  Widget _expenseTab() => ListView(children: [Card(child: Padding(padding: const EdgeInsets.all(16), child: Wrap(spacing: 12, runSpacing: 12, children: [_textField('Category', _expenseCategory), _textField('Description', _expenseDescription), _field('Amount', _expenseAmount), FilledButton(onPressed: _createExpense, child: const Text('Record Expense'))]))), const SizedBox(height: 12), ...expenses.map((x) => ListTile(title: Text('${x['category']} • ${x['description']}'), subtitle: Text('₹${x['amount']}'), trailing: Text(x['payment_mode'] ?? 'cash')))]);

  @override
  Widget build(BuildContext context) => AppShell(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    Row(children: [const Expanded(child: Text('Accounting & GST', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold))), if (loading) const SizedBox(width: 20, height: 20, child: CircularProgressIndicator()), IconButton(onPressed: _loadAll, icon: const Icon(Icons.refresh))]),
    const SizedBox(height: 8), const Text('Sales invoices, kitchen purchase bills, vendor balances, expenses and GST-ready records.'),
    const SizedBox(height: 20), TabBar(isScrollable: true, controller: _tabs, tabs: const [Tab(text: 'GST Summary'), Tab(text: 'Sales Invoices'), Tab(text: 'Purchase Bills'), Tab(text: 'Vendors'), Tab(text: 'Expenses')]),
    const SizedBox(height: 16), Expanded(child: TabBarView(controller: _tabs, children: [_gstTab(), _salesTab(), _purchaseTab(), _vendorsTab(), _expenseTab()]))
  ]));
}
