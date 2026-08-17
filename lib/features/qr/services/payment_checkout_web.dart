import 'dart:async';
import 'dart:js_interop';

@JS('Razorpay')
extension type _Razorpay._(JSObject _) implements JSObject {
  external _Razorpay(JSObject options);
  external void on(JSString event, JSFunction handler);
  external void open();
}

class PaymentCheckout {
  Future<Map<String, dynamic>?> open({
    required String keyId,
    required String amount,
    required String currency,
    required String orderId,
    required String name,
    String? phone,
  }) {
    final completer = Completer<Map<String, dynamic>?>();

    void completeError(Object error) {
      if (!completer.isCompleted) completer.completeError(error);
    }

    final handler = (JSAny? response) {
      try {
        final data = response?.dartify();
        if (data is! Map) {
          completeError(StateError('Invalid payment response.'));
          return;
        }
        final map = Map<String, dynamic>.from(data);
        if (!completer.isCompleted) {
          completer.complete({
            'razorpay_payment_id': map['razorpay_payment_id']?.toString(),
            'razorpay_order_id': map['razorpay_order_id']?.toString(),
            'razorpay_signature': map['razorpay_signature']?.toString(),
          });
        }
      } catch (_) {
        completeError(StateError('Invalid payment response.'));
      }
    };

    final options = <String, dynamic>{
      'key': keyId,
      'amount': amount,
      'currency': currency,
      'name': name,
      'description': 'SpiceOS table order',
      'order_id': orderId,
      'prefill': {
        'name': name,
        if (phone != null && phone.isNotEmpty) 'contact': phone,
      },
      'handler': handler.toJS,
      'modal': {
        'confirm_close': true,
        'ondismiss': (() {
          if (!completer.isCompleted) completer.complete(null);
        }).toJS,
      },
    }.jsify();

    try {
      final razorpay = _Razorpay(options);
      razorpay.on('payment.failed'.toJS, ((JSAny? _) {
        completeError(StateError('Payment failed. Please try again.'));
      }).toJS);
      razorpay.open();
    } catch (error) {
      completeError(error);
    }

    return completer.future;
  }
}
