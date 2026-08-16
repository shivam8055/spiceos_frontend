import 'package:flutter_test/flutter_test.dart';

void main() {
  const staffRoles = {'owner', 'manager', 'staff'};
  const managementRoles = {'owner', 'manager'};

  bool canAccess(String location, String role) {
    if (location == '/settings') {
      return role == 'owner';
    }
    if (location == '/reports' || location == '/delivery') {
      return managementRoles.contains(role);
    }
    if ({
      '/orders',
      '/orders/new',
      '/customers',
      '/inventory',
      '/kitchen',
    }.contains(location)) {
      return staffRoles.contains(role);
    }
    return true;
  }

  test('owner can access management and settings routes', () {
    expect(canAccess('/settings', 'owner'), isTrue);
    expect(canAccess('/reports', 'owner'), isTrue);
    expect(canAccess('/delivery', 'owner'), isTrue);
  });

  test('manager can access operations but not settings', () {
    expect(canAccess('/reports', 'manager'), isTrue);
    expect(canAccess('/delivery', 'manager'), isTrue);
    expect(canAccess('/orders', 'manager'), isTrue);
    expect(canAccess('/settings', 'manager'), isFalse);
  });

  test('staff can access operational routes but not management routes', () {
    expect(canAccess('/orders', 'staff'), isTrue);
    expect(canAccess('/inventory', 'staff'), isTrue);
    expect(canAccess('/kitchen', 'staff'), isTrue);
    expect(canAccess('/reports', 'staff'), isFalse);
    expect(canAccess('/delivery', 'staff'), isFalse);
    expect(canAccess('/settings', 'staff'), isFalse);
  });
}
