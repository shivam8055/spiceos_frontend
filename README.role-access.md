Role-aware navigation is implemented in `lib/app/router.dart` using `RolePermissions`.

Backend authorization remains authoritative; this frontend layer prevents users from navigating to screens their role should not use.
