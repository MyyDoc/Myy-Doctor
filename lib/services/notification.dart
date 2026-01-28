import 'package:firebase_database/firebase_database.dart';

class NotificationService {
  static final DatabaseReference _db =
      FirebaseDatabase.instance.ref();

  /// 🔔 Create notification (call this from anywhere)
  static Future<void> createNotification({
    required String receiverId,
    required String senderId,
    required String type,
    required String text,
    String? entityId,
  }) async {
    final ref = _db.child('notifications/$receiverId').push();

    await ref.set({
      "senderId": senderId,
      "type": type,
      "text": text,
      "entityId": entityId,
      "createdAt": ServerValue.timestamp,
      "read": false,
    });
  }

  /// 👀 Listen to notifications (real-time)
  static Query notificationQuery(String userId) {
    return _db
        .child('notifications/$userId')
        .orderByChild('createdAt');
  }

  /// ✅ Mark notification as read
  static Future<void> markAsRead({
    required String userId,
    required String notificationId,
  }) async {
    await _db
        .child('notifications/$userId/$notificationId/read')
        .set(true);
  }

  /// 🔢 Get unread count
  static Query unreadCountQuery(String userId) {
    return _db
        .child('notifications/$userId')
        .orderByChild('read')
        .equalTo(false);
  }
}