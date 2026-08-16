import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/spiceos_user.dart';
import '../repositories/auth_repository.dart';
import 'auth_provider.dart';

class AuthNotifier extends StateNotifier<AsyncValue<SpiceOsUser?>> {
  AuthNotifier(this._repository) : super(const AsyncLoading()) {
    _initialize();
  }

  final AuthRepository _repository;

  Future<void> _initialize() async {
    await loadCurrentUser();
  }

  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.signIn(email: email, password: password);
      return _repository.getCurrentSpiceOsUser();
    });
  }

  Future<void> register({
    required String email,
    required String password,
  }) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.register(email: email, password: password);
      return _repository.getCurrentSpiceOsUser();
    });
  }

  Future<void> loadCurrentUser() async {
    if (!_repository.isLoggedIn) {
      state = const AsyncData(null);
      return;
    }

    state = const AsyncLoading();
    state = await AsyncValue.guard(_repository.getCurrentSpiceOsUser);
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _repository.signOut();
      return null;
    });
  }
}

final authNotifierProvider = StateNotifierProvider<AuthNotifier, AsyncValue<SpiceOsUser?>>(
  (ref) => AuthNotifier(ref.read(authRepositoryProvider)),
);
