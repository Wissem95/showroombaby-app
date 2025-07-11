# 🔐 Authentification Partie 1 - Service & Providers

## Service d'authentification

### 1. Auth Service (core/services/auth_service.dart)

```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/api_response.dart';
import '../../app/constants/api_constants.dart';

class AuthService {
  final Dio _dio;
  final SharedPreferences _prefs;

  AuthService(this._dio, this._prefs);

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _dio.post(
        ApiConstants.login,
        data: {
          'email': email,
          'password': password,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Sauvegarder le token
      await _saveToken(authResponse.accessToken);
      await _saveUser(authResponse.user);

      return authResponse;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      final response = await _dio.post(
        ApiConstants.register,
        data: {
          'email': email,
          'password': password,
          'username': username,
        },
      );

      final authResponse = AuthResponse.fromJson(response.data);

      // Sauvegarder le token
      await _saveToken(authResponse.accessToken);
      await _saveUser(authResponse.user);

      return authResponse;
    } catch (e) {
      throw _handleAuthError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post(ApiConstants.logout);
    } catch (e) {
      // Ignorer les erreurs de logout côté serveur
    } finally {
      await _clearSession();
    }
  }

  Future<User?> checkAuth() async {
    final token = await getToken();
    if (token == null) return null;

    try {
      final response = await _dio.get(ApiConstants.checkAuth);
      return User.fromJson(response.data['user']);
    } catch (e) {
      await _clearSession();
      return null;
    }
  }

  Future<void> _saveToken(String token) async {
    await _prefs.setString('auth_token', token);
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  Future<void> _saveUser(User user) async {
    await _prefs.setString('user_data', jsonEncode(user.toJson()));
  }

  Future<String?> getToken() async {
    return _prefs.getString('auth_token');
  }

  Future<User?> getStoredUser() async {
    final userData = _prefs.getString('user_data');
    if (userData == null) return null;

    try {
      final json = jsonDecode(userData);
      return User.fromJson(json);
    } catch (e) {
      return null;
    }
  }

  Future<void> _clearSession() async {
    await _prefs.remove('auth_token');
    await _prefs.remove('user_data');
    _dio.options.headers.remove('Authorization');
  }

  String _handleAuthError(dynamic error) {
    if (error is DioException) {
      if (error.response?.statusCode == 422) {
        final errors = error.response?.data['errors'];
        if (errors != null) {
          return errors.values.first[0];
        }
      } else if (error.response?.statusCode == 401) {
        return 'Email ou mot de passe incorrect';
      }
    }
    return 'Une erreur est survenue';
  }
}
```

### 2. Auth Provider (core/providers/auth_provider.dart)

```dart
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../services/auth_service.dart';
import 'dio_provider.dart';
import 'shared_preferences_provider.dart';

part 'auth_provider.g.dart';

@riverpod
AuthService authService(AuthServiceRef ref) {
  final dio = ref.watch(dioProvider);
  final prefs = ref.watch(sharedPreferencesProvider);
  return AuthService(dio, prefs);
}

@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<User?> build() async {
    // Vérifier l'authentification au démarrage
    final authService = ref.read(authServiceProvider);
    return await authService.checkAuth();
  }

  Future<void> login(String email, String password) async {
    state = const AsyncValue.loading();

    try {
      final authService = ref.read(authServiceProvider);
      final authResponse = await authService.login(email, password);
      state = AsyncValue.data(authResponse.user);
    } catch (e) {
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
      final authService = ref.read(authServiceProvider);
      final authResponse = await authService.register(
        email: email,
        password: password,
        username: username,
      );
      state = AsyncValue.data(authResponse.user);
    } catch (e) {
      state = AsyncValue.error(e, StackTrace.current);
      rethrow;
    }
  }

  Future<void> logout() async {
    final authService = ref.read(authServiceProvider);
    await authService.logout();
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
```

### 3. Providers de base (core/providers/base_providers.dart)

```dart
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../app/constants/api_constants.dart';

part 'base_providers.g.dart';

@riverpod
Future<SharedPreferences> sharedPreferences(SharedPreferencesRef ref) async {
  return await SharedPreferences.getInstance();
}

@riverpod
Dio dio(DioRef ref) {
  final dio = Dio();

  dio.options.baseUrl = ApiConstants.baseUrl;
  dio.options.connectTimeout = const Duration(seconds: 30);
  dio.options.receiveTimeout = const Duration(seconds: 30);

  // Intercepteur pour logs en debug
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
    ),
  );

  // Intercepteur pour gestion d'erreurs
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) {
        if (error.response?.statusCode == 401) {
          // Token expiré, déconnecter l'utilisateur
          // Vous pouvez ajouter une logique pour rediriger vers login
        }
        return handler.next(error);
      },
    ),
  );

  return dio;
}
```

Cette première partie configure les services et providers de base pour l'authentification.
