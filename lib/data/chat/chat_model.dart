
import 'package:cloud_firestore/cloud_firestore.dart';

class ChatRoom {
  final String id;
  final List<String> participants;
  final Map<String, dynamic>? lastMessage;
  final Timestamp? lastMessageTime;

  ChatRoom({
    required this.id,
    required this.participants,
    this.lastMessage,
    this.lastMessageTime,
  });

  factory ChatRoom.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ChatRoom(
      id: doc.id,
      participants: List<String>.from(data['participants'] ?? []),
      lastMessage: data['lastMessage'],
      lastMessageTime: data['lastMessageTime'],
    );
  }
}