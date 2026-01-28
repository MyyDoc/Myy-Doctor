import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String id;
  final String text;
  final String senderId;
  final DateTime? createdAt;
  final String type;
  final List<String> readBy;
  final String? status;          // NEW: 'pending', 'cancelled', 'accepted', etc.

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    this.createdAt,
    required this.type,
    required this.readBy,
    this.status,
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
      status: data['status'] as String?,  // ← read status field
    );
  }

  // Optional: toMap method if you ever need to write messages from client
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : FieldValue.serverTimestamp(),
      'type': type,
      'readBy': readBy,
      'status': status,
    };
  }
}