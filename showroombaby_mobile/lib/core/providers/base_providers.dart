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

  // Headers par défaut
  dio.options.headers = {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // Intercepteur pour logs en debug
  dio.interceptors.add(
    LogInterceptor(
      requestBody: true,
      responseBody: true,
      logPrint: (object) => print('DIO: $object'),
    ),
  );

  // Intercepteur pour gestion d'erreurs
  dio.interceptors.add(
    InterceptorsWrapper(
      onError: (error, handler) {
        print('Erreur HTTP: ${error.response?.statusCode} - ${error.message}');
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