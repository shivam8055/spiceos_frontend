import 'dart:async';
import 'dart:js' as js;

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
    final options = js.JsObject.jsify({
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
      'handler': js.allowInterop((dynamic response) {
        try {
          final map = js.JsObject.fromBrowserObject(response);
          completer.complete({
            'razorpay_payment_id': map['razorpay_payment_id']?.toString(),
            'razorpay_order_id': map['razorpay_order_id']?.toString(),
            'razorpay_signature': map['razorpay_signature']?.toString(),
          });
        } catch (_) {
          if (!completer.isCompleted) completer.completeError(StateError('Invalid payment response.'));
        }
      }),
      'modal': {
        'confirm_close': true,
      },
    });

    try {
      final constructor = js.context['Razorpay'];
      if (constructor == null) {
        throw StateError('Payment checkout is unavailable. Please refresh and try again.');
      }
      final razorpay = js.JsObject(constructor, [options]);
      razorpay.callMethod('on', [
        'payment.failed',
        js.allowInterop((dynamic response) {
          if (!completer.isCompleted) {
            completer.completeError(StateError('Payment failed. Please try again.'));
          }
        }),
      ]);
      razorpay.callMethod('open');
    } catch (error) {
      if (!completer.isCompleted) completer.completeError(error);
    }

    return completer.future;
  }
}
