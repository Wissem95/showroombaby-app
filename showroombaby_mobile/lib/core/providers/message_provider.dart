import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/conversation.dart';
import '../models/message.dart';
import '../services/message_service.dart';
import 'base_providers.dart';

part 'message_provider.g.dart';

final messageServiceProvider = Provider<MessageService>((ref) {
  final dio = ref.watch(dioProvider);
  return MessageService(dio);
});

/// Provider pour récupérer toutes les conversations
@riverpod
Future<List<Conversation>> userConversations(UserConversationsRef ref) async {
  final messageService = ref.watch(messageServiceProvider);
  return messageService.getConversations();
}

/// Provider pour récupérer les messages d'une conversation spécifique
/// Chaque conversation est maintenant distincte par (utilisateur, produit)
@riverpod
Future<List<Message>> conversationMessages(
  ConversationMessagesRef ref,
  int userId, {
  int? productId,
}) async {
  final messageService = ref.watch(messageServiceProvider);
  return messageService.getConversationMessages(userId, productId: productId);
}



/// Provider pour récupérer le nombre de messages non lus
@riverpod
Future<int> unreadMessagesCount(UnreadMessagesCountRef ref) async {
  final messageService = ref.watch(messageServiceProvider);
  return messageService.getUnreadCount();
}

/// Provider pour gérer les actions sur les messages
@riverpod
class MessageActions extends _$MessageActions {
  @override
  void build() {
    // Initial state
  }

  /// Envoie un nouveau message
  Future<Message> sendMessage({
    required int receiverId,
    required String content,
    int? productId,
  }) async {
    final messageService = ref.watch(messageServiceProvider);
    final message = await messageService.sendMessage(
      receiverId: receiverId,
      content: content,
      productId: productId,
    );

    // Invalider les providers liés pour mettre à jour l'UI
    ref.invalidate(userConversationsProvider);
    // Invalider le provider de messages spécifique à cette conversation
    ref.invalidate(conversationMessagesProvider(receiverId, productId: productId));
    ref.invalidate(unreadMessagesCountProvider);

    return message;
  }

  /// Marque un message comme lu
  Future<void> markAsRead(int messageId) async {
    final messageService = ref.watch(messageServiceProvider);
    await messageService.markAsRead(messageId);

    // Invalider le compteur de non lus
    ref.invalidate(unreadMessagesCountProvider);
  }

  /// Archive une conversation
  Future<void> archiveConversation(int userId) async {
    final messageService = ref.watch(messageServiceProvider);
    await messageService.archiveConversation(userId);

    // Invalider les conversations pour mettre à jour l'UI
    ref.invalidate(userConversationsProvider);
  }

  /// Désarchive une conversation
  Future<void> unarchiveConversation(int userId) async {
    final messageService = ref.watch(messageServiceProvider);
    await messageService.unarchiveConversation(userId);

    // Invalider les conversations pour mettre à jour l'UI
    ref.invalidate(userConversationsProvider);
  }
} 