
import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String senderId;
  final DateTime? createdAt;
  final String type;
  final List<String> readBy;

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    this.createdAt,
    required this.type,
    required this.readBy,
  });

  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Message(
      id: doc.id,
      text: data['text'] ?? '',
      senderId: data['senderId'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      type: data['type'] ?? 'text',
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }
}
