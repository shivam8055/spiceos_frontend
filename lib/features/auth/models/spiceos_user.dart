class SpiceOsUser {
  const SpiceOsUser({
    required this.id,
    required this.firebaseUid,
    required this.email,
    required this.role,
    required this.isActive,
    this.name,
    this.createdAt,
    this.updatedAt,
  });

  final int id;
  final String firebaseUid;
  final String email;
  final String? name;
  final String role;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory SpiceOsUser.fromJson(Map<String, dynamic> json) {
    return SpiceOsUser(
      id: json['id'] as int,
      firebaseUid: json['firebase_uid'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      role: json['role'] as String,
      isActive: json['is_active'] as bool,
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'] as String)
          : null,
    );
  }

  bool get isOwner => role == 'owner';

  bool get isManager => role == 'manager';

  bool get isStaff => role == 'staff';
}