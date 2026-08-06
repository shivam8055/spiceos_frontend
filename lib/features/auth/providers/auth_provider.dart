import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repository.dart';
import '../repositories/firebase_auth_repository.dart';



final firebaseAuthProvider = Provider<FirebaseAuth>(
      (ref) => FirebaseAuth.instance,
);

final authRepositoryProvider = Provider<AuthRepository>(
      (ref) => FirebaseAuthRepository(
    ref.read(firebaseAuthProvider),
  ),
);

final authStateProvider = StreamProvider<bool>(
      (ref) {
    return ref.read(authRepositoryProvider).authStateChanges();
  },
);