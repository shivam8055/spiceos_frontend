import '../models/spiceos_user.dart';

abstract class AuthRepository {
  Stream<bool> authStateChanges();

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> register({
    required String email,
    required String password,
  });

  Future<void> signOut();

  Future<SpiceOsUser> getCurrentSpiceOsUser();

  bool get isLoggedIn;
}