import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;

class AuthApiTestService {
  AuthApiTestService({
    FirebaseAuth? firebaseAuth,
  }) : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  final FirebaseAuth _firebaseAuth;

  Future<http.Response> testAuthenticatedRequest({
    required String baseUrl,
  }) async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception(
        'No Firebase user is currently signed in.',
      );
    }

    final idToken = await user.getIdToken();

    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Unable to obtain Firebase ID token.',
      );
    }

    return http.get(
      Uri.parse('$baseUrl/auth/me'),
      headers: {
        'Authorization': 'Bearer $idToken',
        'Content-Type': 'application/json',
      },
    );
  }
}