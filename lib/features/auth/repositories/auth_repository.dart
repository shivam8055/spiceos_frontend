abstract class AuthRepository {
  Stream<bool> authStateChanges();

  Future<void> signIn({
    required String email,
    required String password,
  });

  Future<void> signOut();

  bool get isLoggedIn;
}