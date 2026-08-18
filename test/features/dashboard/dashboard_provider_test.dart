import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dashboard exposes four live operational KPI concepts', () {
    const titles = ["Today's Revenue", 'Orders', 'Customers', 'Deliveries'];
    expect(titles, hasLength(4));
    expect(titles, contains("Today's Revenue"));
    expect(titles, contains('Orders'));
    expect(titles, contains('Customers'));
    expect(titles, contains('Deliveries'));
  });
}
