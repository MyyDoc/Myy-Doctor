
// ==================== NOTIFICATION MODEL ====================
class NotificationModel {
  final String notificationId;
  final String userId;
  final String type;
  final String content;
  final String? relatedId;
  final String? relatedUserId;
  final bool isRead;
  final DateTime createdAt;

  NotificationModel({
    required this.notificationId,
    required this.userId,
    required this.type,
    required this.content,
    this.relatedId,
    this.relatedUserId,
    this.isRead = false,
    required this.createdAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'notificationId': notificationId,
      'userId': userId,
      'type': type,
      'content': content,
      'relatedId': relatedId,
      'relatedUserId': relatedUserId,
      'isRead': isRead,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      notificationId: json['notificationId'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? 'system',
      content: json['content'] ?? '',
      relatedId: json['relatedId'],
      relatedUserId: json['relatedUserId'],
      isRead: json['isRead'] ?? false,
      createdAt: json['createdAt'] != null ? DateTime.parse(json['createdAt']) : DateTime.now(),
    );
  }
}
