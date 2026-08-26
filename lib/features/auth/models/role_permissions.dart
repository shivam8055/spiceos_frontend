class RolePermissions {
  const RolePermissions._();

  static const owner = 'owner';
  static const manager = 'manager';
  static const staff = 'staff';

  static const staffRoles = {owner, manager, staff};
  static const managementRoles = {owner, manager};
  static const ownerRoles = {owner};

  static bool canAccess(String location, String role) {
    if (location == '/settings' || location == '/qr-tables') {
      return ownerRoles.contains(role);
    }

    if (location == '/reports' || location == '/delivery' || location == '/accounting') {
      return managementRoles.contains(role);
    }

    if (location == '/orders' ||
        location == '/orders/new' ||
        location == '/customers' ||
        location == '/inventory' ||
        location == '/kitchen' ||
        location == '/menu') {
      return staffRoles.contains(role);
    }

    return true;
  }
}
