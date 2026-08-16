import 'package:flutter_test/flutter_test.dart';
import 'package:spicebox/features/auth/models/role_permissions.dart';

void main() {
  test('owner can access management and settings routes', () {
    expect(RolePermissions.canAccess('/settings', RolePermissions.owner), isTrue);
    expect(RolePermissions.canAccess('/reports', RolePermissions.owner), isTrue);
    expect(RolePermissions.canAccess('/delivery', RolePermissions.owner), isTrue);
  });

  test('manager can access operations but not settings', () {
    expect(RolePermissions.canAccess('/reports', RolePermissions.manager), isTrue);
    expect(RolePermissions.canAccess('/delivery', RolePermissions.manager), isTrue);
    expect(RolePermissions.canAccess('/orders', RolePermissions.manager), isTrue);
    expect(RolePermissions.canAccess('/settings', RolePermissions.manager), isFalse);
  });

  test('staff can access operational routes but not management routes', () {
    expect(RolePermissions.canAccess('/orders', RolePermissions.staff), isTrue);
    expect(RolePermissions.canAccess('/inventory', RolePermissions.staff), isTrue);
    expect(RolePermissions.canAccess('/kitchen', RolePermissions.staff), isTrue);
    expect(RolePermissions.canAccess('/reports', RolePermissions.staff), isFalse);
    expect(RolePermissions.canAccess('/delivery', RolePermissions.staff), isFalse);
    expect(RolePermissions.canAccess('/settings', RolePermissions.staff), isFalse);
  });
}
