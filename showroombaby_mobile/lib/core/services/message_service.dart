import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../app/constants/api_constants.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../models/api_response.dart';

class MessageService {
  final Dio _dio;
  SharedPreferences? _prefs;

  MessageService(this._dio);

  /// Lazy initialization de SharedPreferences
  Future<SharedPreferences> _getPrefs() async {
    _prefs ??= await SharedPreferences.getInstance();
    return _prefs!;
  }

  /// Récupère toutes les conversations de l'utilisateur
  Future<List<Conversation>> getConversations() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/messages/conversations',
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData['data'] != null) {
          final conversationsList = responseData['data'] as List;
          return conversationsList
              .map((json) => Conversation.fromJson(json as Map<String, dynamic>))
              .toList();
        } else {
          throw Exception('Format de réponse inattendu pour les conversations');
        }
      } else {
        throw Exception('Erreur lors du chargement des conversations');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Vous devez être connecté pour voir vos messages');
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupère les messages d'une conversation avec un utilisateur
  Future<List<Message>> getConversationMessages(int userId, {int? productId}) async {
    try {
      // Construire les paramètres de la requête
      final Map<String, dynamic> queryParams = {};
      if (productId != null) {
        queryParams['productId'] = productId.toString();
      }
      
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/messages/conversation/$userId',
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData['data'] != null) {
          final List<dynamic> messagesData = responseData['data'];
          return messagesData.map((json) => Message.fromJson(json)).toList();
        }
      }

      throw DioException(
        requestOptions: response.requestOptions,
        response: response,
        message: 'Format de réponse invalide',
      );
    } catch (e) {
      if (e is DioException) {
        throw e;
      }
      throw DioException(
        requestOptions: RequestOptions(path: ''),
        message: 'Erreur lors de la récupération des messages: $e',
      );
    }
  }

  /// Envoie un nouveau message
  Future<Message> sendMessage({
    required int receiverId,
    required String content,
    int? productId,
  }) async {
    try {
      final response = await _dio.post(
        '${ApiConstants.baseUrl}/messages',
        data: {
          'recipientId': receiverId, // Corrigé de 'receiver_id' à 'recipientId'
          'content': content,
          if (productId != null) 'productId': productId, // Corrigé de 'product_id' à 'productId'
        },
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode == 201) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic> && responseData['data'] != null) {
          return Message.fromJson(responseData['data'] as Map<String, dynamic>);
        } else {
          throw Exception('Format de réponse inattendu pour l\'envoi du message');
        }
      } else {
        throw Exception('Erreur lors de l\'envoi du message');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Vous devez être connecté pour envoyer des messages');
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Marque un message comme lu
  Future<void> markAsRead(int messageId) async {
    try {
      await _dio.post(
        '${ApiConstants.baseUrl}/messages/$messageId/read',
        options: Options(
          headers: await _getHeaders(),
        ),
      );
    } on DioException catch (e) {
      // Ignore l'erreur si le message est déjà lu
      if (e.response?.statusCode != 404) {
        throw Exception('Erreur lors du marquage du message: ${e.message}');
      }
    }
  }

  /// Récupère le nombre de messages non lus
  Future<int> getUnreadCount() async {
    try {
      final response = await _dio.get(
        '${ApiConstants.baseUrl}/messages/unread/count',
        options: Options(
          headers: await _getHeaders(),
        ),
      );

      if (response.statusCode == 200) {
        final responseData = response.data;
        if (responseData is Map<String, dynamic>) {
          return responseData['count'] ?? 0;
        }
      }
      return 0;
    } on DioException catch (e) {
      // En cas d'erreur, retourner 0
      return 0;
    }
  }

  /// Archive une conversation
  Future<void> archiveConversation(int userId) async {
    try {
      await _dio.post(
        '${ApiConstants.baseUrl}/messages/conversation/$userId/archive',
        options: Options(
          headers: await _getHeaders(),
        ),
      );
    } on DioException catch (e) {
      throw Exception('Erreur lors de l\'archivage: ${e.message}');
    }
  }

  /// Désarchive une conversation
  Future<void> unarchiveConversation(int userId) async {
    try {
      await _dio.post(
        '${ApiConstants.baseUrl}/messages/conversation/$userId/unarchive',
        options: Options(
          headers: await _getHeaders(),
        ),
      );
    } on DioException catch (e) {
      throw Exception('Erreur lors du désarchivage: ${e.message}');
    }
  }

  /// Headers pour les requêtes API avec token d'authentification
  Future<Map<String, String>> _getHeaders() async {
    final prefs = await _getPrefs();
    final token = prefs.getString('auth_token');
    
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }
} 