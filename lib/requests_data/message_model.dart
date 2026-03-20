class ChatMessage {
  final String id;
  final String senderId;
  final String senderName;
  final String content;
  final DateTime timestamp;
  bool isRead;

  ChatMessage({
    required this.id,
    required this.senderId,
    required this.senderName,
    required this.content,
    required this.timestamp,
    this.isRead = false,
  });
}

class Conversation {
  final String id;
  final String clientId;
  final String clientName;
  final String workerId;
  final String workerName;
  final String? requestId;
  final String? requestTitle;
  final String? requestType;
  final List<ChatMessage> messages;

  Conversation({
    required this.id,
    required this.clientId,
    required this.clientName,
    required this.workerId,
    required this.workerName,
    this.requestId,
    this.requestTitle,
    this.requestType,
    List<ChatMessage>? messages,
  }) : messages = messages ?? [];

  ChatMessage? get lastMessage =>
      messages.isEmpty ? null : messages.last;

  int unreadCountFor(String userId) =>
      messages.where((m) => !m.isRead && m.senderId != userId).length;

  String displayNameFor(String userId) {
    if (userId == clientId) return 'Repairman: $workerName';
    return clientName;
  }
}
