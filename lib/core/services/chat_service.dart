import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/chat/chat_model.dart';
import '../../data/chat/message_model.dart';

/// Service class to handle all chat-related operations
class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _currentUserId = FirebaseAuth.instance.currentUser?.uid ?? '';

  /// Generates a consistent chat room ID (smaller UID first)
  String _generateChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return 'chat_${ids[0]}_${ids[1]}';
  }

  /// Get or create a chat room between current user and another user
  Future<String> getOrCreateChatRoom(String otherUserId) async {
    if (_currentUserId.isEmpty) {
      throw Exception("User not authenticated");
    }

    final chatId = _generateChatId(_currentUserId, otherUserId);
    final chatRef = _firestore.collection('chats').doc(chatId);

    final snapshot = await chatRef.get();

    if (!snapshot.exists) {
      await chatRef.set({
        'participants': [_currentUserId, otherUserId],
        'createdAt': FieldValue.serverTimestamp(),
        'lastMessageTime': FieldValue.serverTimestamp(),
        'lastMessage': null,
        'unreadCount': {
          _currentUserId: 0,
          otherUserId: 0,
        },
      });
    }

    return chatId;
  }

  /// Send a text message + increment unread count for the receiver
  Future<void> sendTextMessage({
    required String chatId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final messageRef = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc();

    final batch = _firestore.batch();

    // Add the message
    batch.set(messageRef, {
      'text': text.trim(),
      'senderId': _currentUserId,
      'createdAt': FieldValue.serverTimestamp(),
      'type': 'text',
      'readBy': [_currentUserId],
    });

    // Get current chat to find the other participant
    final chatDoc = await _firestore.collection('chats').doc(chatId).get();
    final participants = List<String>.from(chatDoc.data()?['participants'] ?? []);
    final otherUid = participants.firstWhere(
          (id) => id != _currentUserId,
      orElse: () => '',
    );

    // Update metadata + increment unread for receiver
    final updateData = {
      'lastMessage': {
        'text': text.trim().length > 80
            ? '${text.trim().substring(0, 80)}...'
            : text.trim(),
        'senderId': _currentUserId,
        'createdAt': FieldValue.serverTimestamp(),
        'type': 'text',
      },
      'lastMessageTime': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (otherUid.isNotEmpty) {
      updateData['unreadCount.$otherUid'] = FieldValue.increment(1);
    }

    batch.update(_firestore.collection('chats').doc(chatId), updateData);

    await batch.commit();
  }

  /// Stream of messages in a chat (real-time)
  Stream<List<Message>> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }

  /// Stream of all user's active chats
  Stream<List<ChatRoom>> getUserChats() {
    if (_currentUserId.isEmpty) return Stream.value([]);

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: _currentUserId)
        .orderBy('lastMessageTime', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ChatRoom.fromFirestore(doc)).toList();
    });
  }

  /// Reset unread count to 0 for current user when they open the chat
  Future<void> markChatAsRead(String chatId) async {
    if (_currentUserId.isEmpty) return;

    await _firestore.collection('chats').doc(chatId).update({
      'unreadCount.$_currentUserId': 0,
    });
  }

  /// Get the other participant in a chat room
  Future<String?> getOtherParticipant(String chatId) async {
    final doc = await _firestore.collection('chats').doc(chatId).get();
    if (!doc.exists) return null;

    final participants = List<String>.from(doc.data()?['participants'] ?? []);
    return participants.firstWhere(
          (id) => id != _currentUserId,
      orElse: () => '',
    );
  }

  /// Helper: Check if current user has unread messages in this chat
  Future<bool> hasUnreadMessages(String chatId) async {
    if (_currentUserId.isEmpty) return false;

    final doc = await _firestore.collection('chats').doc(chatId).get();
    if (!doc.exists) return false;

    final unreadMap = doc.data()?['unreadCount'] as Map<String, dynamic>?;
    if (unreadMap == null) return false;

    final count = (unreadMap[_currentUserId] as num?)?.toInt() ?? 0;
    return count > 0;
  }
}