import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../repositories/auth_repository.dart';
import 'auth_provider.dart';

class AuthNotifier extends StateNotifier<AsyncValue<void>> {
  AuthNotifier(this._repository) : super(const AsyncData(null));

  final AuthRepository _repository;

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.signIn(
        email: email,
        password: password,
      );
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      await _repository.signOut();
    });
  }
}

final authNotifierProvider =
StateNotifierProvider<AuthNotifier, AsyncValue<void>>(
      (ref) => AuthNotifier(
    ref.read(authRepositoryProvider),
  ),
);