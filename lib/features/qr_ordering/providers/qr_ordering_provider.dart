import 'dart:async';
import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/network/api_client.dart';
import '../models/qr_menu.dart';
import '../models/qr_order.dart';
import '../repositories/qr_ordering_repository.dart';

class QROrderingState {
  final bool loading;
  final bool submitting;
  final QRMenu? menu;
  final List<QRCartLine> cart;
  final QROrderConfirmation? confirmation;
  final QROrderStatus? status;
  final String? error;

  const QROrderingState({this.loading = true, this.submitting = false, this.menu, this.cart = const [], this.confirmation, this.status, this.error});

  double get cartTotal => cart.fold<double>(0, (sum, line) => sum + line.total);
  int get cartCount => cart.fold<int>(0, (sum, line) => sum + line.quantity);

  QROrderingState copyWith({
    bool? loading,
    bool? submitting,
    QRMenu? menu,
    List<QRCartLine>? cart,
    QROrderConfirmation? confirmation,
    QROrderStatus? status,
    String? error,
    bool clearError = false,
    bool clearConfirmation = false,
    bool clearStatus = false,
  }) => QROrderingState(
        loading: loading ?? this.loading,
        submitting: submitting ?? this.submitting,
        menu: menu ?? this.menu,
        cart: cart ?? this.cart,
        confirmation: clearConfirmation ? null : confirmation ?? this.confirmation,
        status: clearStatus ? null : status ?? this.status,
        error: clearError ? null : error ?? this.error,
      );
}

class QROrderingNotifier extends StateNotifier<QROrderingState> {
  QROrderingNotifier(this._repository, this.token) : super(const QROrderingState()) {
    loadMenu();
    _restoreOrder();
  }

  final QROrderingRepository _repository;
  final String token;
  Timer? _statusTimer;
  String? _idempotencyKey;

  String get _storagePrefix => 'spiceos_qr_${token.hashCode}';

  Future<void> loadMenu() async {
    state = state.copyWith(loading: true, clearError: true);
    try {
      final menu = await _repository.getMenu(token);
      state = state.copyWith(loading: false, menu: menu);
    } catch (error) {
      state = state.copyWith(loading: false, error: qrErrorMessage(error));
    }
  }

  Future<void> _restoreOrder() async {
    final preferences = await SharedPreferences.getInstance();
    final savedPublicToken = preferences.getString('$_storagePrefix.public_token');
    if (savedPublicToken == null || savedPublicToken.isEmpty) return;
    try {
      final status = await _repository.getOrderStatus(savedPublicToken);
      final confirmation = QROrderConfirmation(
        orderId: -1,
        orderNumber: status.orderNumber,
        status: status.status,
        total: status.total,
        currency: status.currency,
        tableName: status.tableName,
        publicOrderToken: savedPublicToken,
      );
      state = state.copyWith(confirmation: confirmation, status: status);
      _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) => refreshStatus());
    } catch (_) {
      await preferences.remove('$_storagePrefix.public_token');
      await preferences.remove('$_storagePrefix.idempotency_key');
    }
  }

  void addToCart(QRMenuItem item, {List<QRModifier> modifiers = const [], String note = ''}) {
    if (!item.available || state.confirmation != null) return;
    final index = state.cart.indexWhere((line) =>
        line.item.id == item.id &&
        line.note == note &&
        line.modifiers.map((e) => e.id).toSet().containsAll(modifiers.map((e) => e.id)) &&
        modifiers.map((e) => e.id).toSet().containsAll(line.modifiers.map((e) => e.id)));
    final cart = [...state.cart];
    if (index >= 0) {
      cart[index] = cart[index].copyWith(quantity: cart[index].quantity + 1);
    } else {
      cart.add(QRCartLine(item: item, quantity: 1, modifiers: modifiers, note: note));
    }
    state = state.copyWith(cart: cart);
  }

  void updateQuantity(int index, int quantity) {
    if (index < 0 || index >= state.cart.length || state.confirmation != null) return;
    final cart = [...state.cart];
    if (quantity <= 0) {
      cart.removeAt(index);
    } else {
      cart[index] = cart[index].copyWith(quantity: quantity);
    }
    state = state.copyWith(cart: cart);
  }

  Future<void> submit({String? customerName, String? customerPhone}) async {
    if (state.cart.isEmpty || state.submitting || state.confirmation != null) return;
    _idempotencyKey ??= _newIdempotencyKey();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('$_storagePrefix.idempotency_key', _idempotencyKey!);
    state = state.copyWith(submitting: true, clearError: true);
    try {
      final confirmation = await _repository.createOrder(
        token: token,
        idempotencyKey: _idempotencyKey!,
        lines: state.cart,
        customerName: customerName,
        customerPhone: customerPhone,
      );
      await preferences.setString('$_storagePrefix.public_token', confirmation.publicOrderToken);
      state = state.copyWith(submitting: false, confirmation: confirmation);
      await refreshStatus();
      _statusTimer?.cancel();
      _statusTimer = Timer.periodic(const Duration(seconds: 5), (_) => refreshStatus());
    } catch (error) {
      state = state.copyWith(submitting: false, error: qrErrorMessage(error));
    }
  }

  Future<void> refreshStatus() async {
    final confirmation = state.confirmation;
    if (confirmation == null) return;
    try {
      final status = await _repository.getOrderStatus(confirmation.publicOrderToken);
      state = state.copyWith(status: status);
      if ({'delivered', 'cancelled'}.contains(status.status)) _statusTimer?.cancel();
    } catch (_) {
      // Preserve the last known status during transient network failures.
    }
  }

  Future<void> startNewOrder() async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.remove('$_storagePrefix.public_token');
    await preferences.remove('$_storagePrefix.idempotency_key');
    _idempotencyKey = null;
    _statusTimer?.cancel();
    state = state.copyWith(cart: [], clearConfirmation: true, clearStatus: true, clearError: true);
  }

  static String _newIdempotencyKey() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return bytes.map((value) => value.toRadixString(16).padLeft(2, '0')).join();
  }

  @override
  void dispose() {
    _statusTimer?.cancel();
    super.dispose();
  }
}

final qrOrderingRepositoryProvider = Provider<QROrderingRepository>((ref) => QROrderingRepository(ref.watch(apiClientProvider)));

final qrOrderingProvider = StateNotifierProvider.autoDispose.family<QROrderingNotifier, QROrderingState, String>(
  (ref, token) => QROrderingNotifier(ref.watch(qrOrderingRepositoryProvider), token),
);
