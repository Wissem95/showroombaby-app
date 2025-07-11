import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'base_providers.dart';

part 'user_provider.g.dart';

final userServiceProvider = Provider<UserService>((ref) {
  final dio = ref.watch(dioProvider);
  return UserService(dio);
});

/// Provider pour récupérer les informations d'un utilisateur spécifique
@riverpod
Future<User> userProfile(UserProfileRef ref, int userId) async {
  final userService = ref.watch(userServiceProvider);
  final user = await userService.getUserProfile(userId);
  if (user == null) {
    throw Exception('Utilisateur $userId non trouvé');
  }
  return user;
} 