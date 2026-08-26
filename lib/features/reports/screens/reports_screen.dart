import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/network/api_client.dart';
import '../../../core/widgets/app_shell.dart';

class ReportsScreen extends ConsumerStatefulWidget {
  const ReportsScreen({super.key});

  @override
  ConsumerState<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends ConsumerState<ReportsScreen> {
  int _days = 30;
  late Future<Map<String, dynamic>> _reportFuture;

  @override
  void initState() {
    super.initState();
    _reportFuture = _loadReport();
  }

  Future<Map<String, dynamic>> _loadReport() async {
    final end = DateTime.now();
    final start = end.subtract(Duration(days: _days - 1));
    String iso(DateTime value) =>
        '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

    final response = await ref.read(apiClientProvider).get(
      '/reports/summary?start_date=${iso(start)}&end_date=${iso(end)}',
    );
    return Map<String, dynamic>.from(response.data as Map);
  }

  void _changeRange(int? value) {
    if (value == null) return;
    setState(() {
      _days = value;
      _reportFuture = _loadReport();
    });
  }

  String _money(dynamic value) => '₹${(value as num?)?.toStringAsFixed(0) ?? '0'}';

  @override
  Widget build(BuildContext context) {
    return AppShell(
      child: FutureBuilder<Map<String, dynamic>>(
        future: _reportFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.cloud_off, size: 48),
                  const SizedBox(height: 12),
                  const Text('Unable to load reports'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => setState(() => _reportFuture = _loadReport()),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          final data = snapshot.data ?? const <String, dynamic>{};
          final kpis = Map<String, dynamic>.from(data['kpis'] as Map? ?? {});
          final sources = List<Map<String, dynamic>>.from(
            (data['by_source'] as List? ?? const []).map((item) => Map<String, dynamic>.from(item as Map)),
          );
          final daily = List<Map<String, dynamic>>.from(
            (data['daily'] as List? ?? const []).map((item) => Map<String, dynamic>.from(item as Map)),
          );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Reports', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
                          SizedBox(height: 4),
                          Text('Sales, orders and operational performance'),
                        ],
                      ),
                    ),
                    DropdownButton<int>(
                      value: _days,
                      items: const [
                        DropdownMenuItem(value: 7, child: Text('Last 7 days')),
                        DropdownMenuItem(value: 30, child: Text('Last 30 days')),
                        DropdownMenuItem(value: 90, child: Text('Last 90 days')),
                      ],
                      onChanged: _changeRange,
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final columns = constraints.maxWidth >= 1100 ? 4 : constraints.maxWidth >= 700 ? 2 : 1;
                    final width = (constraints.maxWidth - (columns - 1) * 16) / columns;
                    return Wrap(
                      spacing: 16,
                      runSpacing: 16,
                      children: [
                        _KpiCard(width: width, title: 'Net Sales', value: _money(kpis['net_sales']), icon: Icons.currency_rupee),
                        _KpiCard(width: width, title: 'Orders', value: '${kpis['total_orders'] ?? 0}', icon: Icons.receipt_long),
                        _KpiCard(width: width, title: 'Average Order', value: _money(kpis['average_order_value']), icon: Icons.shopping_bag),
                        _KpiCard(width: width, title: 'Completion', value: '${kpis['completion_rate'] ?? 0}%', icon: Icons.check_circle_outline),
                      ],
                    );
                  },
                ),
                const SizedBox(height: 24),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final stacked = constraints.maxWidth < 850;
                    final left = _SalesTrendCard(daily: daily);
                    final right = _SourceCard(sources: sources, money: _money);
                    if (stacked) {
                      return Column(children: [left, const SizedBox(height: 16), right]);
                    }
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [Expanded(flex: 2, child: left), const SizedBox(width: 16), Expanded(child: right)],
                    );
                  },
                ),
                const SizedBox(height: 16),
                _OperationalCard(kpis: kpis, money: _money),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _KpiCard extends StatelessWidget {
  const _KpiCard({required this.width, required this.title, required this.value, required this.icon});
  final double width;
  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, size: 28),
              const SizedBox(width: 14),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(title),
                  const SizedBox(height: 6),
                  Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                ]),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SalesTrendCard extends StatelessWidget {
  const _SalesTrendCard({required this.daily});
  final List<Map<String, dynamic>> daily;

  @override
  Widget build(BuildContext context) {
    final recent = daily.length > 14 ? daily.sublist(daily.length - 14) : daily;
    final maxSales = recent.fold<double>(1, (max, item) => ((item['sales'] as num?)?.toDouble() ?? 0) > max ? (item['sales'] as num).toDouble() : max);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Sales trend', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 20),
          if (recent.isEmpty)
            const SizedBox(height: 180, child: Center(child: Text('No sales in this period')))
          else
            SizedBox(
              height: 180,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  for (final item in recent)
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 2),
                        child: Tooltip(
                          message: '${item['date']}: ₹${(item['sales'] as num?)?.toStringAsFixed(0) ?? '0'}',
                          child: FractionallySizedBox(
                            heightFactor: ((item['sales'] as num?)?.toDouble() ?? 0) / maxSales,
                            alignment: Alignment.bottomCenter,
                            child: DecoratedBox(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(4),
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ]),
      ),
    );
  }
}

class _SourceCard extends StatelessWidget {
  const _SourceCard({required this.sources, required this.money});
  final List<Map<String, dynamic>> sources;
  final String Function(dynamic) money;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Sales by source', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
          const SizedBox(height: 12),
          if (sources.isEmpty)
            const Padding(padding: EdgeInsets.symmetric(vertical: 30), child: Text('No orders in this period'))
          else
            ...sources.take(6).map((item) => ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              title: Text('${item['source'] ?? 'Unknown'}'),
              subtitle: Text('${item['orders'] ?? 0} orders'),
              trailing: Text(money(item['sales'])),
            )),
        ]),
      ),
    );
  }
}

class _OperationalCard extends StatelessWidget {
  const _OperationalCard({required this.kpis, required this.money});
  final Map<String, dynamic> kpis;
  final String Function(dynamic) money;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Wrap(
          spacing: 40,
          runSpacing: 18,
          children: [
            _Metric(label: 'Completed', value: '${kpis['completed_orders'] ?? 0}'),
            _Metric(label: 'Cancelled', value: '${kpis['cancelled_orders'] ?? 0}'),
            _Metric(label: 'Pending payments', value: money(kpis['pending_amount'])),
            _Metric(label: 'Refunded', value: money(kpis['refunded_sales'])),
            _Metric(label: 'Cancellation rate', value: '${kpis['cancellation_rate'] ?? 0}%'),
          ],
        ),
      ),
    );
  }
}

class _Metric extends StatelessWidget {
  const _Metric({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label),
        const SizedBox(height: 4),
        Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700)),
      ]),
    );
  }
}
