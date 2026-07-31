import 'package:flutter_riverpod/flutter_riverpod.dart';

final discountProvider = StateProvider<double>((ref) => 0);

final deliveryChargeProvider = StateProvider<double>((ref) => 0);

final gstRateProvider = Provider<double>((ref) => 0.05);

final paymentMethodProvider =
StateProvider<String>((ref) => 'Cash');