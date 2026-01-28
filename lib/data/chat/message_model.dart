import 'package:cloud_firestore/cloud_firestore.dart'; // only if you still need both versions

class Message {
  final String id;
  final String text;
  final String senderId;
  final DateTime createdAt;
  final String type; // 'text', 'appointment_request', etc.
  final String? status; // 'pending', 'accepted', 'rejected', 'cancelled'
  final DateTime? acceptedAt;
  final DateTime? rejectedAt;
  final DateTime? cancelledAt;
  final List<String> readBy;

  // Add other fields you might have (imageUrl, appointmentId, etc.)

  Message({
    required this.id,
    required this.text,
    required this.senderId,
    required this.createdAt,
    required this.type,
    this.status,
    this.acceptedAt,
    this.rejectedAt,
    this.cancelledAt,
    this.readBy = const [],
  });

  // Original Firestore factory (keep if you want dual support)
  factory Message.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final createdAt = (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now();

    return Message(
      id: doc.id,
      text: data['text'] as String? ?? '',
      senderId: data['senderId'] as String? ?? '',
      createdAt: createdAt,
      type: data['type'] as String? ?? 'text',
      status: data['status'] as String?,
      acceptedAt: (data['acceptedAt'] as Timestamp?)?.toDate(),
      rejectedAt: (data['rejectedAt'] as Timestamp?)?.toDate(),
      cancelledAt: (data['cancelledAt'] as Timestamp?)?.toDate(),
      readBy: List<String>.from(data['readBy'] ?? []),
    );
  }

  // New: Realtime Database factory
  factory Message.fromRealtime(String id, Map<dynamic, dynamic> data) {
    final safeData = Map<String, dynamic>.from(data);

    final createdAtMillis = (safeData['createdAt'] as num?)?.toInt() ?? 0;
    final acceptedAtMillis = (safeData['acceptedAt'] as num?)?.toInt();
    final rejectedAtMillis = (safeData['rejectedAt'] as num?)?.toInt();
    final cancelledAtMillis = (safeData['cancelledAt'] as num?)?.toInt();

    return Message(
      id: id,
      text: safeData['text'] as String? ?? '',
      senderId: safeData['senderId'] as String? ?? '',
      createdAt: DateTime.fromMillisecondsSinceEpoch(createdAtMillis),
      type: safeData['type'] as String? ?? 'text',
      status: safeData['status'] as String?,
      acceptedAt: acceptedAtMillis != null && acceptedAtMillis > 0
          ? DateTime.fromMillisecondsSinceEpoch(acceptedAtMillis)
          : null,
      rejectedAt: rejectedAtMillis != null && rejectedAtMillis > 0
          ? DateTime.fromMillisecondsSinceEpoch(rejectedAtMillis)
          : null,
      cancelledAt: cancelledAtMillis != null && cancelledAtMillis > 0
          ? DateTime.fromMillisecondsSinceEpoch(cancelledAtMillis)
          : null,
      readBy: List<String>.from(safeData['readBy'] ?? []),
    );
  }
  // Optional: toJson / toMap if you need to send data
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'senderId': senderId,
      'createdAt': createdAt.millisecondsSinceEpoch,
      'type': type,
      'status': status,
      if (acceptedAt != null) 'acceptedAt': acceptedAt!.millisecondsSinceEpoch,
      if (rejectedAt != null) 'rejectedAt': rejectedAt!.millisecondsSinceEpoch,
      if (cancelledAt != null) 'cancelledAt': cancelledAt!.millisecondsSinceEpoch,
      'readBy': readBy,
    };
  }
}