import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/order_filter.dart';

final orderFilterProvider =
StateProvider<OrderFilter>((ref) => OrderFilter.all);