import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'base_providers.dart';

part 'auth_provider.g.dart';

@riverpod
Future<AuthService> authService(AuthServiceRef ref) async {
  final dio = ref.watch(dioProvider);
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  
  return AuthService(dio, prefs);
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<User?> build() async {
    try {
      final authService = await ref.read(authServiceProvider.future);
      return await authService.checkAuth();
    } catch (e) {
      print('Erreur lors de la vérification auth: $e');
      return null;
    }
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final authService = await ref.read(authServiceProvider.future);
      final authResponse = await authService.login(email, password);
      state = AsyncValue.data(authResponse.user);
    } catch (e) {
      print('Erreur login: $e');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> register({
    required String email,
    required String password,
    required String username,
  }) async {
    state = const AsyncValue.loading();

    try {
      final authService = await ref.read(authServiceProvider.future);
      final authResponse = await authService.register(
        email: email,
        password: password,
        username: username,
      );
      state = AsyncValue.data(authResponse.user);
    } catch (e) {
      print('Erreur register: $e');
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      final authService = await ref.read(authServiceProvider.future);
      await authService.logout();
    } catch (e) {
      print('Erreur lors de la déconnexion: $e');
    }
    state = const AsyncValue.data(null);
  }

  Future<void> updateUser(User user) async {
    state = AsyncValue.data(user);
  }
}

@riverpod
bool isAuthenticated(IsAuthenticatedRef ref) {
  final authState = ref.watch(authNotifierProvider);
  return authState.whenOrNull(data: (user) => user != null) ?? false;
} 