import 'package:firebase_auth/firebase_auth.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/network/api_client.dart';
import '../models/spiceos_user.dart';
import 'auth_repository.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository(
      this._auth,
      this._apiClient,
      );

  final FirebaseAuth _auth;
  final ApiClient _apiClient;

  @override
  Stream<bool> authStateChanges() {
    return _auth.authStateChanges().map(
          (user) => user != null,
    );
  }

  @override
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> register({
    required String email,
    required String password,
  }) async {
    await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Future<SpiceOsUser> getCurrentSpiceOsUser() async {
    final response = await _apiClient.get(
      ApiConstants.authMe,
    );

    if (response.statusCode != 200) {
      throw Exception(
        'Unable to load SpiceOS user '
            '(HTTP ${response.statusCode}).',
      );
    }

    return SpiceOsUser.fromJson(
      Map<String, dynamic>.from(
        response.data as Map,
      ),
    );
  }

  @override
  bool get isLoggedIn => _auth.currentUser != null;
}