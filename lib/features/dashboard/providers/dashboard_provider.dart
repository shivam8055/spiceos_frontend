import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../inventory/providers/inventory_api_provider.dart';
import '../../orders/models/order.dart';
import '../../orders/providers/orders_provider.dart';
import '../models/dashboard_kpi.dart';

final dashboardDataProvider = Provider<List<DashboardKpi>>((ref) {
  final orders = ref.watch(ordersProvider);
  final inventory = ref.watch(inventoryItemsProvider).valueOrNull ?? const [];
  final now = DateTime.now();
  final startOfDay = DateTime(now.year, now.month, now.day);

  final todayOrders = orders.where((order) => !order.createdAt.isBefore(startOfDay)).toList();
  final revenue = todayOrders
      .where((order) => order.paymentStatus == PaymentStatus.paid && order.status != OrderStatus.cancelled)
      .fold<double>(0, (sum, order) => sum + order.totalAmount);
  final customers = todayOrders.map((order) => order.customerId).where((id) => id.isNotEmpty).toSet().length;
  final deliveries = todayOrders.where((order) => order.status == OrderStatus.outForDelivery).length;
  final lowStock = inventory.where((item) => item.isLowStock).length;

  return [
    DashboardKpi(title: "Today's Revenue", value: '₹${revenue.toStringAsFixed(0)}', subtitle: '${todayOrders.length} orders today', positive: true),
    DashboardKpi(title: 'Orders', value: '${todayOrders.length}', subtitle: '${orders.where((o) => o.status == OrderStatus.preparing).length} preparing', positive: true),
    DashboardKpi(title: 'Customers', value: '$customers', subtitle: 'unique customers today', positive: true),
    DashboardKpi(title: 'Deliveries', value: '$deliveries', subtitle: '$lowStock low-stock items', positive: lowStock == 0),
  ];
});

final List<DashboardKpi> dashboardData = const [
  DashboardKpi(title: "Today's Revenue", value: '₹0', subtitle: 'Live data loading', positive: true),
  DashboardKpi(title: 'Orders', value: '0', subtitle: 'Live data loading', positive: true),
  DashboardKpi(title: 'Customers', value: '0', subtitle: 'Live data loading', positive: true),
  DashboardKpi(title: 'Deliveries', value: '0', subtitle: 'Live data loading', positive: true),
];
