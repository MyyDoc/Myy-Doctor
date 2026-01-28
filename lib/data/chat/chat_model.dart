import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final List<String> participants;
  final DateTime? createdAt;
  final DateTime? lastMessageTime;
  final Map<String, dynamic>? lastMessage; // usually {text, senderId, type, createdAt}
  final Map<String, int> unreadCount;

  ChatRoom({
    required this.id,
    required this.participants,
    this.createdAt,
    this.lastMessageTime,
    this.lastMessage,
    this.unreadCount = const {},
  });

  // Original Firestore factory (keep if needed)
  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final createdAtTs = data['createdAt'] as Timestamp?;
    final lastMessageTimeTs = data['lastMessageTime'] as Timestamp?;

    return ChatRoom(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      createdAt: createdAtTs?.toDate(),
      lastMessageTime: lastMessageTimeTs?.toDate(),
      lastMessage: data['lastMessage'] as Map<String, dynamic>?,
      unreadCount: Map<String, int>.from(
        (data['unreadCount'] as Map? ?? {}).map((k, v) => MapEntry(k, (v as num).toInt())),
      ),
    );
  }

  factory ChatRoom.fromRealtime(String id, Map<dynamic, dynamic> data) {
    // Safely convert top-level map
    final safeData = Map<String, dynamic>.from(data);

    final createdAtMillis = (safeData['createdAt'] as num?)?.toInt();
    final lastMessageTimeMillis = (safeData['lastMessageTime'] as num?)?.toInt();

    // unreadCount
    final unreadRaw = safeData['unreadCount'] as Map<dynamic, dynamic>? ?? {};
    final unreadMap = <String, int>{};
    unreadRaw.forEach((key, value) {
      final stringKey = key?.toString();
      if (stringKey != null) {
        final count = (value as num?)?.toInt() ?? 0;
        unreadMap[stringKey] = count;
      }
    });

    // lastMessage - this is the critical fix
    final lastMsgRaw = safeData['lastMessage'];
    final Map<String, dynamic>? lastMessageMap =
    lastMsgRaw is Map ? Map<String, dynamic>.from(lastMsgRaw) : null;

    return ChatRoom(
      id: id,
      participants: List<String>.from(safeData['participants'] ?? []),
      createdAt: createdAtMillis != null && createdAtMillis > 0
          ? DateTime.fromMillisecondsSinceEpoch(createdAtMillis)
          : null,
      lastMessageTime: lastMessageTimeMillis != null && lastMessageTimeMillis > 0
          ? DateTime.fromMillisecondsSinceEpoch(lastMessageTimeMillis)
          : null,
      lastMessage: lastMessageMap,
      unreadCount: unreadMap,
    );
  }
  // Optional helper: get unread count for current user
  int getUnreadFor(String uid) => unreadCount[uid] ?? 0;

  bool hasUnreadFor(String uid) => getUnreadFor(uid) > 0;
}