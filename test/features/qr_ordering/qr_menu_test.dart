import 'package:flutter_test/flutter_test.dart';

import 'package:spicebox/features/qr_ordering/models/qr_menu.dart';

void main() {
  test('QR menu parses server menu and modifier pricing', () {
    final menu = QRMenu.fromJson({
      'context': {
        'restaurant_id': 'r1',
        'branch_id': 'b1',
        'table_id': 't1',
        'table_name': 'Table 4',
        'session_id': 's1',
      },
      'categories': ['Mains'],
      'items': [
        {
          'id': 10,
          'category': 'Mains',
          'name': 'Paneer Tikka',
          'description': 'Test',
          'price': 250,
          'available': true,
          'modifiers': [
            {'id': 'cheese', 'name': 'Extra Cheese', 'price_delta': 40, 'available': true},
          ],
        },
      ],
    });

    final line = QRCartLine(item: menu.items.single, quantity: 2, modifiers: menu.items.single.modifiers);
    expect(menu.tableName, 'Table 4');
    expect(line.unitPrice, 290);
    expect(line.total, 580);
  });

  test('unavailable items remain unavailable from backend payload', () {
    final item = QRMenuItem.fromJson({
      'id': 1,
      'category': 'Mains',
      'name': 'Sold Out',
      'description': null,
      'price': 100,
      'available': false,
      'modifiers': [],
    });
    expect(item.available, isFalse);
  });
}
