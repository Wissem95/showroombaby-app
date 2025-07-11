import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/providers/message_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/user_provider.dart';
import '../../../core/providers/product_provider.dart';
import '../../../core/models/message.dart';
import '../../../shared/widgets/loading_widget.dart';
import '../../../shared/widgets/error_widget.dart';
import '../../../app/theme/app_colors.dart';
import '../../../core/models/product.dart'; // Added import for Product
import '../../../core/models/user.dart'; // Added import for User

class ConversationScreen extends ConsumerStatefulWidget {
  final int userId;
  final int? productId;

  const ConversationScreen({
    super.key,
    required this.userId,
    this.productId,
  });

  @override
  ConsumerState<ConversationScreen> createState() => _ConversationScreenState();
}

class _ConversationScreenState extends ConsumerState<ConversationScreen> {
  // Variables d'état
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _isSending = false;
  bool _hasText = false;
  bool _showSuggestions = false; // Afficher les suggestions de messages

  @override
  void initState() {
    super.initState();
    
    // Ajouter un listener pour mettre à jour l'état du bouton d'envoi
    _messageController.addListener(() {
      final hasText = _messageController.text.trim().isNotEmpty;
      
      if (hasText != _hasText) {
        setState(() {
          _hasText = hasText;
        });
      }
    });

    // Vérifier s'il faut afficher les suggestions de messages
    if (widget.productId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkAndShowSuggestions();
      });
    }
  }

  // Vérifier s'il y a déjà des messages et afficher les suggestions si nécessaire
  Future<void> _checkAndShowSuggestions() async {
    try {
      // Utiliser le provider spécifique à cette conversation (utilisateur + produit)
      final messages = await ref.read(conversationMessagesProvider(widget.userId, productId: widget.productId).future);
      
      // Si aucun message et que c'est pour un produit, afficher les suggestions
      if (messages.isEmpty && widget.productId != null) {
        setState(() {
          _showSuggestions = true;
        });
      }
    } catch (e) {
      // En cas d'erreur, ne pas afficher les suggestions
      print('Erreur lors de la vérification des messages: $e');
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // Formatage de l'heure du message
  String _formatMessageTime(DateTime? dateTime) {
    if (dateTime == null) return '';
    
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays == 0) {
      // Aujourd'hui - afficher l'heure
      return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else if (difference.inDays == 1) {
      // Hier
      return 'Hier ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    } else {
      // Plus ancienne - afficher la date
      return '${dateTime.day}/${dateTime.month} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
    }
  }

  // Sélectionner une suggestion de message
  void _selectSuggestion(String suggestion) {
    _messageController.text = suggestion;
    setState(() {
      _hasText = true;
      _showSuggestions = false; // Masquer les suggestions après sélection
    });
  }

  // Liste des suggestions de messages
  List<String> get _messageSuggestions => [
    "Bonjour, est-ce que ce produit est toujours disponible ?",
    "Quel est l'état exact du produit ?",
    "Le prix est-il négociable ?",
    "Où peut-on se rencontrer pour l'échange ?",
  ];

  // Envoyer un message
  Future<void> _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty || _isSending) return;

    setState(() {
      _isSending = true;
    });

    try {
      await ref.read(messageActionsProvider.notifier).sendMessage(
        receiverId: widget.userId,
        content: content,
        productId: widget.productId,
      );

      _messageController.clear();
      setState(() {
        _hasText = false;
        _showSuggestions = false; // Masquer les suggestions après l'envoi
      });
      
      // Faire défiler vers le bas après l'envoi
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }

      // Rafraîchir les messages avec le provider spécifique
      ref.refresh(conversationMessagesProvider(widget.userId, productId: widget.productId));
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur lors de l\'envoi du message: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSending = false;
        });
      }
    }
  }

  // Méthodes helper pour formater les informations

  /// Construit le texte de localisation du produit
  String _buildLocationText(Product product) {
    final parts = <String>[];
    
    if (product.city != null && product.city!.isNotEmpty) {
      parts.add(product.city!);
    }
    
    if (product.zipcode != null && product.zipcode!.isNotEmpty) {
      parts.add(product.zipcode!);
    }
    
    if (parts.isEmpty && product.address != null && product.address!.isNotEmpty) {
      // Si pas de ville/code postal, utiliser l'adresse
      parts.add(product.address!);
    }
    
    return parts.isNotEmpty ? parts.join(', ') : 'Localisation non spécifiée';
  }

  /// Construit le nom d'affichage du vendeur
  String _buildSellerName(User seller) {
    if (seller.name != null && seller.name!.isNotEmpty) {
      return seller.name!;
    }
    
    if (seller.firstName != null || seller.lastName != null) {
      final firstName = seller.firstName ?? '';
      final lastName = seller.lastName ?? '';
      final fullName = '$firstName $lastName'.trim();
      if (fullName.isNotEmpty) {
        return fullName;
      }
    }
    
    if (seller.username != null && seller.username!.isNotEmpty) {
      return seller.username!;
    }
    
    return 'Utilisateur ${seller.id}';
  }

  // Méthode pour construire l'image du produit
  Widget _buildProductImage(Product product) {
    if (product.images != null && product.images!.isNotEmpty) {
      return Image.network(
        product.images!.first.url,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) => Icon(
          Icons.shopping_bag,
          color: Colors.grey[600],
          size: 30,
        ),
      );
    }
    return Icon(
      Icons.shopping_bag,
      color: Colors.grey[600],
      size: 30,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authNotifierProvider).value;
    // Utiliser le provider spécifique à cette conversation (utilisateur + produit)
    final messagesAsync = ref.watch(conversationMessagesProvider(widget.userId, productId: widget.productId));
    
    // Récupérer les vraies informations utilisateur et produit
    final otherUserAsync = ref.watch(userProfileProvider(widget.userId));
    final productAsync = widget.productId != null 
        ? ref.watch(productDetailsProvider(widget.productId!))
        : null;

    // Si l'utilisateur n'est pas connecté
    if (user == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Conversation'),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('Vous devez être connecté pour voir cette conversation'),
        ),
      );
    }

    // Déterminer le nom d'affichage basé sur les vraies informations de l'utilisateur
    String otherUserDisplayName = 'Utilisateur ${widget.userId}';
    
    otherUserAsync.whenData((otherUser) {
      otherUserDisplayName = _buildSellerName(otherUser);
    });

    // Déterminer le titre du produit si disponible
    String productTitle = 'Produit #${widget.productId}';
    if (productAsync != null) {
      productAsync.whenData((product) {
        if (product.title.isNotEmpty) {
          productTitle = product.title;
        }
      });
    }

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              otherUserDisplayName,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (widget.productId != null)
              Text(
                'À propos de: $productTitle',
                style: const TextStyle(fontSize: 12, color: Colors.grey),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.call),
            onPressed: () {
              // TODO: Implémenter l'appel téléphonique
            },
          ),
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () {
              // TODO: Implémenter le menu options
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Carte du produit améliorée si applicable
          if (widget.productId != null && productAsync != null)
            _buildProductCardWithData(productAsync),

          // Zone des messages
          Expanded(
            child: messagesAsync.when(
              data: (messages) => _buildMessagesList(messages, user),
              loading: () => const LoadingWidget(),
              error: (error, stack) => CustomErrorWidget(
                message: 'Erreur lors du chargement des messages: $error',
                onRetry: () => ref.refresh(conversationMessagesProvider(widget.userId, productId: widget.productId)),
              ),
            ),
          ),

          // Suggestions de messages
          _buildMessageSuggestions(),

          // Zone de saisie du message
          _buildMessageInput(),
        ],
      ),
    );
  }

  // Nouvelle méthode pour construire la carte du produit avec les vraies données
  Widget _buildProductCardWithData(AsyncValue<Product> productAsync) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: productAsync.when(
        data: (product) {
          return Row(
            children: [
              // Image du produit
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  width: 60,
                  height: 60,
                  color: Colors.grey[200],
                  child: _buildProductImage(product),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    if (product.price != null)
                      Text(
                        '${product.price!.toStringAsFixed(0)}€',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 18,
                          color: AppColors.primary,
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text(
                      _buildLocationText(product),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    // Nom du vendeur - récupérer via le provider utilisateur
                    _buildSellerInfo(product.userId),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () => context.push('/product/${widget.productId}'),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue[100],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.open_in_new,
                    color: Colors.blue[600],
                    size: 20,
                  ),
                ),
              ),
            ],
          );

          // Fallback si pas de produit trouvé - cette partie n'est plus nécessaire
          // car le provider lance maintenant une exception au lieu de retourner null
        },
        loading: () => Row(
          children: [
            Icon(
              Icons.shopping_bag,
              color: Colors.blue[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Chargement des informations du produit...',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
        error: (error, stack) => Row(
          children: [
            Icon(
              Icons.shopping_bag,
              color: Colors.blue[600],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Discussion à propos du produit #${widget.productId}',
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget pour afficher les informations du vendeur
  Widget _buildSellerInfo(int sellerId) {
    final sellerAsync = ref.watch(userProfileProvider(sellerId));
    
    return sellerAsync.when(
      data: (seller) {
        return Text(
          'Vendeur: ${_buildSellerName(seller)}',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[500],
            fontStyle: FontStyle.italic,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        );
      },
      loading: () => Text(
        'Vendeur: Chargement...',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[500],
          fontStyle: FontStyle.italic,
        ),
      ),
      error: (error, stack) => Text(
        'Vendeur: Utilisateur $sellerId',
        style: TextStyle(
          fontSize: 11,
          color: Colors.grey[500],
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  // Méthode pour construire la liste des messages
  Widget _buildMessagesList(List<Message> messages, User user) {
    if (messages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'Aucun message',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Commencez la conversation en envoyant un message',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Inverser les messages pour avoir les plus récents en bas
    final reversedMessages = messages.reversed.toList();

    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.all(16),
      itemCount: reversedMessages.length,
      itemBuilder: (context, index) {
        final message = reversedMessages[index];
        final isFromCurrentUser = message.senderId == user.id;
        
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          child: Row(
            mainAxisAlignment: isFromCurrentUser 
                ? MainAxisAlignment.end 
                : MainAxisAlignment.start,
            children: [
              if (!isFromCurrentUser) ...[
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  backgroundImage: message.sender?.avatar != null
                      ? NetworkImage(message.sender!.avatar!)
                      : null,
                  child: message.sender?.avatar == null
                      ? Text(
                          // Utiliser les vraies informations utilisateur
                          message.sender?.name?.substring(0, 1).toUpperCase() ??
                          message.sender?.firstName?.substring(0, 1).toUpperCase() ??
                          message.sender?.username?.substring(0, 1).toUpperCase() ??
                          'U',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: 8),
              ],
              
              // Bulle de message
              Flexible(
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isFromCurrentUser 
                        ? AppColors.primary 
                        : Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message.content,
                        style: TextStyle(
                          color: isFromCurrentUser 
                              ? Colors.white 
                              : Colors.black87,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _formatMessageTime(message.createdAt),
                            style: TextStyle(
                              color: isFromCurrentUser 
                                  ? Colors.white.withOpacity(0.8)
                                  : Colors.grey[600],
                              fontSize: 12,
                            ),
                          ),
                          if (isFromCurrentUser) ...[
                            const SizedBox(width: 4),
                            Icon(
                              message.read 
                                  ? Icons.done_all 
                                  : Icons.done,
                              size: 16,
                              color: message.read 
                                  ? Colors.blue[200]
                                  : Colors.white.withOpacity(0.8),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              
              if (isFromCurrentUser) ...[
                const SizedBox(width: 8),
                CircleAvatar(
                  radius: 16,
                  backgroundColor: AppColors.primary.withOpacity(0.2),
                  backgroundImage: user.avatar != null
                      ? NetworkImage(user.avatar!)
                      : null,
                  child: user.avatar == null
                      ? Text(
                          // Utiliser les vraies informations de l'utilisateur connecté
                          user.name?.substring(0, 1).toUpperCase() ??
                          user.firstName?.substring(0, 1).toUpperCase() ??
                          user.username?.substring(0, 1).toUpperCase() ??
                          'M',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        )
                      : null,
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  // Widget pour afficher les suggestions de messages
  Widget _buildMessageSuggestions() {
    if (!_showSuggestions) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        border: Border(
          top: BorderSide(color: Colors.grey[200]!),
          bottom: BorderSide(color: Colors.grey[200]!),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppColors.primary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                'Messages suggérés',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _messageSuggestions.map((suggestion) {
              return GestureDetector(
                onTap: () => _selectSuggestion(suggestion),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 2,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Text(
                    suggestion,
                    style: TextStyle(
                      color: AppColors.primary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  // Méthode pour construire la zone de saisie du message
  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Champ de saisie
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    hintText: 'Tapez votre message...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 12),

            // Bouton d'envoi
            Container(
              decoration: BoxDecoration(
                color: _hasText && !_isSending
                    ? AppColors.primary
                    : Colors.grey[300],
                shape: BoxShape.circle,
              ),
              child: IconButton(
                onPressed: _isSending ? null : _sendMessage,
                icon: _isSending
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.grey[600],
                        ),
                      )
                    : const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 20,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 