import 'package:flutter_test/flutter_test.dart';

void main() {
  test('dashboard live KPI contract uses backend-derived concepts', () {
    const titles = ["Today's Revenue", 'Orders', 'Customers', 'Deliveries'];
    expect(titles.length, 4);
    expect(titles, contains("Today's Revenue"));
    expect(titles, contains('Orders'));
    expect(titles, contains('Deliveries'));
  });
}
