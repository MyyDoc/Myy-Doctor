import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myydoctor/services/notification.dart';

import '../../data/chat/chat_model.dart';
import '../../data/chat/message_model.dart';

/// Service class to handle all chat-related operations — Realtime Database version
class ChatService {
  static final ChatService _instance = ChatService._internal();
  factory ChatService() => _instance;
  ChatService._internal();

  final FirebaseDatabase _database = FirebaseDatabase.instance;
  String get _currentUserId => FirebaseAuth.instance.currentUser?.uid ?? '';

  DatabaseReference get _chatsRef => _database.ref('chats');

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
    final chatRef = _chatsRef.child(chatId);

    final snapshot = await chatRef.get();

    if (!snapshot.exists) {
      await chatRef.set({
        'participants': [_currentUserId, otherUserId],
        'createdAt': ServerValue.timestamp,
        'lastMessageTime': ServerValue.timestamp,
        'lastMessage': null,
        'unreadCount': {_currentUserId: 0, otherUserId: 0},
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

    final messagesRef = _chatsRef.child('$chatId/messages');
    final newMessageRef = messagesRef.push();

    final now = ServerValue.timestamp;

    final messageData = {
      'text': text.trim(),
      'senderId': _currentUserId,
      'createdAt': now,
      'type': 'text',
      'readBy': [_currentUserId],
    };

    // We'll do two writes — RTDB doesn't have batches like Firestore
    await newMessageRef.set(messageData);

    // Get current chat to find the other participant
    final chatSnapshot = await _chatsRef.child(chatId).get();
    final participants = (chatSnapshot.value as Map?)?['participants'] as List?;
    final otherUid = participants?.firstWhere(
      (id) => id != _currentUserId,
      orElse: () => null,
    );

    if (otherUid == null) return;

    final truncatedText =
        text.trim().length > 80
            ? '${text.trim().substring(0, 80)}...'
            : text.trim();

    await _chatsRef.child(chatId).update({
      'lastMessage': {
        'text': truncatedText,
        'senderId': _currentUserId,
        'createdAt': now,
        'type': 'text',
      },
      'lastMessageTime': now,
      'updatedAt': now,
      'unreadCount/$otherUid': ServerValue.increment(1),
    });
  }

  /// Stream of messages in a chat (real-time) — newest first
  Stream<List<Message>> getMessages(String chatId) {
    final messagesRef = _chatsRef.child('$chatId/messages');

    return messagesRef.orderByChild('createdAt').onValue.map((event) {
      final data = event.snapshot.value as Map<dynamic, dynamic>?;
      if (data == null) return <Message>[];

      final list =
          data.entries.map((entry) {
            final key = entry.key as String;
            final val = entry.value as Map<dynamic, dynamic>;
            return Message.fromRealtime(key, val);
          }).toList();

      list.sort((a, b) => b.createdAt.compareTo(a.createdAt)); // newest first
      return list;
    });
  }

  /// Stream of all user's active chats — ordered by lastMessageTime
  Stream<List<ChatRoom>> getUserChats() {
    if (_currentUserId.isEmpty) {
      print("getUserChats → currentUserId is EMPTY → returning []");
      return Stream.value([]);
    }

    print("getUserChats → listening for UID: $_currentUserId");

    return _chatsRef
        .orderByChild('lastMessageTime')
        .onValue
        .asBroadcastStream()
        .map((event) {
      final snap = event.snapshot;

      print("----------------------------------------");
      print("getUserChats snapshot received");
      print("Exists: ${snap.exists}");
      print("Key: ${snap.key}");
      print("Value type: ${snap.value.runtimeType}");

      if (!snap.exists || snap.value == null) {
        print("→ No data at /chats or empty snapshot");
        return <ChatRoom>[];
      }

      final data = snap.value as Map<dynamic, dynamic>?;
      if (data == null || data.isEmpty) {
        print("→ data is null or empty map");
        return <ChatRoom>[];
      }

      print("Found ${data.length} chat entries in /chats");

      final List<ChatRoom> validChats = [];

      data.forEach((dynamic key, dynamic value) {
        final chatId = key as String?;
        if (chatId == null) return;

        final chatData = value as Map<dynamic, dynamic>?;
        if (chatData == null) {
          print("Chat $chatId → value is not a map");
          return;
        }

        print("→ Processing chat: $chatId");

        final participantsRaw = chatData['participants'];
        print(
          "  participants raw: $participantsRaw (type: ${participantsRaw.runtimeType})",
        );

        List<dynamic>? participants;
        if (participantsRaw is List) {
          participants = participantsRaw;
        } else if (participantsRaw is Map) {
          // sometimes people accidentally save as map
          participants = participantsRaw.values.toList();
          print("  → converted map participants to list");
        } else {
          print(
            "  → participants is invalid type: ${participantsRaw.runtimeType}",
          );
          return;
        }

        final containsMe = participants.contains(_currentUserId);
        print("  contains current user ($_currentUserId)? → $containsMe");

        if (!containsMe) {
          print("  → SKIPPING: current user not in participants");
          return;
        }

        try {
          final room = ChatRoom.fromRealtime(chatId, chatData);
          validChats.add(room);
          print("  → SUCCESS: parsed ChatRoom for $chatId");
          print("     lastMessageTime: ${room.lastMessageTime}");
          print("     unread for me: ${room.unreadCount[_currentUserId]}");
        } catch (e, stack) {
          print("  → ERROR parsing ChatRoom $chatId: $e");
          print("     Stack: $stack");
        }
      });

      print("Final valid chats count: ${validChats.length}");
      print("----------------------------------------");

      return validChats;
    });
  }

  /// Send appointment request + create appointment record
  Future<void> sendAppointmentRequestMessage(String chatId) async {
    if (_currentUserId.isEmpty) return;

    // Check for existing pending request (client-side filter)
    final apptsRef = _chatsRef.child('$chatId/appointments');
    final apptsSnap = await apptsRef.get();
    final appts = apptsSnap.value as Map?;
    final hasPending =
        appts?.values.any(
          (v) =>
              (v as Map)['requesterId'] == _currentUserId &&
              (v as Map)['status'] == 'pending',
        ) ??
        false;

    if (hasPending) return;

    final now = ServerValue.timestamp;

    // 1️⃣ Send chat message
    final messagesRef = _chatsRef.child('$chatId/messages');
    final newMsgRef = messagesRef.push();

    const appointmentText =
        "I want to book an appointment.\nWhen can I visit the clinic?";

    await newMsgRef.set({
      'text': appointmentText,
      'senderId': _currentUserId,
      'createdAt': now,
      'type': 'appointment_request',
      'readBy': [_currentUserId],
      'status': 'pending',
    });

    // 2️⃣ Create appointment record
    final apptRef = apptsRef.push();
    await apptRef.set({
      'requesterId': _currentUserId,
      'status': 'pending',
      'createdAt': now,
      'messageId': newMsgRef.key,
    });

    // 3️⃣ Find other participant (doctor)
    final chatSnap = await _chatsRef.child(chatId).get();
    final participants = (chatSnap.value as Map?)?['participants'] as List?;

    final otherUid = participants?.firstWhere(
      (id) => id != _currentUserId,
      orElse: () => null,
    );

    if (otherUid == null) return;

    // 4️⃣ Update chat metadata
    await _chatsRef.child(chatId).update({
      'lastMessage': {
        'text': 'Appointment Request',
        'senderId': _currentUserId,
        'createdAt': now,
        'type': 'appointment_request',
      },
      'lastMessageTime': now,
      'updatedAt': now,
      'unreadCount/$otherUid': ServerValue.increment(1),
    });

    // 🔔 5️⃣ SEND APPOINTMENT NOTIFICATION (NEW)
    await NotificationService.createNotification(
      receiverId: otherUid, // doctor
      senderId: _currentUserId, // patient
      type: 'appointment_request',
      text: 'requested an appointment',
      entityId: chatId, // open chat on tap
    );
  }

  Future<void> cancelAppointmentRequest({
    required String chatId,
    required String messageId,
  }) async {
    final now = ServerValue.timestamp;

    await _chatsRef.child('$chatId/messages/$messageId').update({
      'status': 'cancelled',
      'cancelledAt': now,
    });

    final apptsSnap = await _chatsRef.child('$chatId/appointments').get();
    final appts = apptsSnap.value as Map?;
    String? apptKey;

    appts?.forEach((key, value) {
      if ((value as Map)['messageId'] == messageId) {
        apptKey = key;
      }
    });

    if (apptKey != null) {
      await _chatsRef.child('$chatId/appointments/$apptKey').update({
        'status': 'cancelled',
        'cancelledAt': now,
      });
    }
  }

  Future<Map<String, dynamic>?> getPendingAppointment(String chatId) async {
    final apptsSnap = await _chatsRef.child('$chatId/appointments').get();
    final appts = apptsSnap.value as Map?;

    if (appts == null) return null;

    for (final entry in appts.entries) {
      final val = entry.value as Map;
      if (val['requesterId'] == _currentUserId && val['status'] == 'pending') {
        return {...val, 'id': entry.key};
      }
    }
    return null;
  }

  Future<void> acceptAppointment({
    required String chatId,
    required String messageId,
  }) async {
    final now = ServerValue.timestamp;

    // 1️⃣ Update message status
    await _chatsRef.child('$chatId/messages/$messageId').update({
      'status': 'accepted',
      'acceptedAt': now,
    });

    // 2️⃣ Find appointment record
    final apptsSnap = await _chatsRef.child('$chatId/appointments').get();
    String? apptKey;
    String? patientId;

    (apptsSnap.value as Map?)?.forEach((key, val) {
      final map = val as Map;
      if (map['messageId'] == messageId) {
        apptKey = key;
        patientId = map['requesterId'];
      }
    });

    if (apptKey != null && patientId != null) {
      // 3️⃣ Update appointment
      await _chatsRef.child('$chatId/appointments/$apptKey').update({
        'status': 'accepted',
        'acceptedAt': now,
        'doctorId': _currentUserId,
      });

      // 🔔 4️⃣ SEND NOTIFICATION TO PATIENT
      await NotificationService.createNotification(
        receiverId: patientId!,
        senderId: _currentUserId, // doctor
        type: 'appointment_accepted',
        text: 'accepted your appointment',
        entityId: chatId,
      );
    }
  }

  Future<void> rejectAppointment({
    required String chatId,
    required String messageId,
  }) async {
    final now = ServerValue.timestamp;

    // 1️⃣ Update message status
    await _chatsRef.child('$chatId/messages/$messageId').update({
      'status': 'rejected',
      'rejectedAt': now,
    });

    // 2️⃣ Find appointment record
    final apptsSnap = await _chatsRef.child('$chatId/appointments').get();
    String? apptKey;
    String? patientId;

    (apptsSnap.value as Map?)?.forEach((key, val) {
      final map = val as Map;
      if (map['messageId'] == messageId) {
        apptKey = key;
        patientId = map['requesterId'];
      }
    });

    if (apptKey != null && patientId != null) {
      // 3️⃣ Update appointment
      await _chatsRef.child('$chatId/appointments/$apptKey').update({
        'status': 'rejected',
        'rejectedAt': now,
      });

      // 🔔 4️⃣ SEND NOTIFICATION TO PATIENT
      await NotificationService.createNotification(
        receiverId: patientId!,
        senderId: _currentUserId, // doctor
        type: 'appointment_rejected',
        text: 'rejected your appointment',
        entityId: chatId,
      );
    }
  }

  /// Reset unread count to 0 for current user when they open the chat
  Future<void> markChatAsRead(String chatId) async {
    if (_currentUserId.isEmpty) return;
    await _chatsRef.child('$chatId/unreadCount/$_currentUserId').set(0);
  }

  Future<String?> getOtherParticipant(String chatId) async {
    final snap = await _chatsRef.child('$chatId/participants').get();
    final list = snap.value as List?;
    if (list == null) return null;
    return list.firstWhere((id) => id != _currentUserId, orElse: () => null);
  }

  Future<bool> hasUnreadMessages(String chatId) async {
    if (_currentUserId.isEmpty) return false;
    final snap =
        await _chatsRef.child('$chatId/unreadCount/$_currentUserId').get();
    final count = (snap.value as num?)?.toInt() ?? 0;
    return count > 0;
  }
}
