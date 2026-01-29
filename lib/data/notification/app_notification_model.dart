class AppNotificationModel {
  final String id;
  final String senderId;
  final String type; // follow, appointment_request, message, etc
  final String text;
  final String? entityId; // chatId, appointmentId, userId
  final int createdAt;
  final bool read;

  AppNotificationModel({
    required this.id,
    required this.senderId,
    required this.type,
    required this.text,
    this.entityId,
    required this.createdAt,
    required this.read,
  });

  factory AppNotificationModel.fromMap(String id, Map data) {
    return AppNotificationModel(
      id: id,
      senderId: data['senderId'],
      type: data['type'],
      text: data['text'],
      entityId: data['entityId'],
      createdAt:
          data['createdAt'] is int
              ? data['createdAt']
              : 0, // 👈 fallback for safety
      read: data['read'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      "senderId": senderId,
      "type": type,
      "text": text,
      "entityId": entityId,
      "createdAt": createdAt,
      "read": read,
    };
  }
}
