import 'message_model.dart';

class MessagesDatabase {
  static final List<Conversation> _conversations = [];

  static List<Conversation> getConversationsForUser(String userId) {
    return _conversations
        .where((c) => c.clientId == userId || c.workerId == userId)
        .toList()
      ..sort((a, b) {
        final aTime = a.lastMessage?.timestamp ?? DateTime(2000);
        final bTime = b.lastMessage?.timestamp ?? DateTime(2000);
        return bTime.compareTo(aTime);
      });
  }

  static int totalUnreadFor(String userId) => getConversationsForUser(userId)
      .fold(0, (sum, c) => sum + c.unreadCountFor(userId));

  static Conversation? getById(String id) {
    for (final c in _conversations) {
      if (c.id == id) return c;
    }
    return null;
  }

  static Conversation createOrGet({
    required String clientId,
    required String clientName,
    required String workerId,
    required String workerName,
    String? requestId,
    String? requestTitle,
    String? requestType,
  }) {
    for (final c in _conversations) {
      if (c.clientId == clientId &&
          c.workerId == workerId &&
          c.requestId == requestId) {
        return c;
      }
    }
    final conv = Conversation(
      id: 'conv_${DateTime.now().millisecondsSinceEpoch}',
      clientId: clientId,
      clientName: clientName,
      workerId: workerId,
      workerName: workerName,
      requestId: requestId,
      requestTitle: requestTitle,
      requestType: requestType,
    );
    _conversations.add(conv);
    return conv;
  }

  static void sendMessage({
    required String conversationId,
    required String senderId,
    required String senderName,
    required String content,
  }) {
    getById(conversationId)?.messages.add(ChatMessage(
      id: 'msg_${DateTime.now().millisecondsSinceEpoch}',
      senderId: senderId,
      senderName: senderName,
      content: content,
      timestamp: DateTime.now(),
    ));
  }

  static void markAllAsRead({
    required String conversationId,
    required String userId,
  }) {
    final conv = getById(conversationId);
    if (conv == null) return;
    for (final msg in conv.messages) {
      if (msg.senderId != userId) msg.isRead = true;
    }
  }
}
