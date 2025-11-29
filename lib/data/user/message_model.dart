
// ==================== MESSAGE MODEL ====================
class MessageModel {
  final String messageId;
  final String senderId;
  final String receiverId;
  final String chatId;
  final String content;
  final String messageType;
  final DateTime createdAt;
  final bool isRead;
  final Map<String, String> reactions;

  MessageModel({
    required this.messageId,
    required this.senderId,
    required this.receiverId,
    required this.chatId,
    required this.content,
    this.messageType = 'text',
    required this.createdAt,
    this.isRead = false,
    this.reactions = const {},
  });

  Map<String, dynamic> toJson() {
    return {
      'messageId': messageId,
      'senderId': senderId,
      'receiverId': receiverId,
      'chatId': chatId,
      'content': content,
      'messageType': messageType,
      'createdAt': createdAt.toIso8601String(),
      'isRead': isRead,
      'reactions': reactions,
    };
  }

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      messageId: json['messageId'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      chatId: json['chatId'] ?? '',
      content: json['content'] ?? '',
      messageType: json['messageType'] ?? 'text',
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
      isRead: json['isRead'] ?? false,
      reactions: Map<String, String>.from(json['reactions'] ?? {}),
    );
  }
}
