import 'package:flutter/material.dart';

import '../../../core/services/chat_service.dart';
import '../../screens/chat/chat_screen.dart';

class MessageBubble extends StatelessWidget {
  final LocalMessageAdapter message;
  final String type;
  final String? status;
  final String? messageId;
  final String? appointmentId;
  final VoidCallback? onCancel;
  final String? chatId;

  const MessageBubble({
    super.key,
    required this.message,
    this.type = 'text',
    this.status,
    this.messageId,
    this.appointmentId,
    this.onCancel,
    this.chatId
  });

  @override
  Widget build(BuildContext context) {
    final isMe = message.isMe;
    final alignment = isMe ? Alignment.centerRight : Alignment.centerLeft;

    if (type == 'appointment_request') {
      final isPending = status == 'pending';
      final isAccepted = status == 'accepted';
      final isRejected = status == 'rejected';
      final isCancelled = status == 'cancelled';

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
        child: Align(
          alignment: alignment,
          child: IntrinsicWidth(
            child: Container(
              decoration: BoxDecoration(
                color: isCancelled || isRejected
                    ? Colors.grey.shade300
                    : isAccepted
                    ? Colors.green.shade100
                    : const Color(0xFFE3EBF3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [

                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      isCancelled
                          ? "Appointment cancelled"
                          : isRejected
                          ? "Appointment rejected"
                          : isAccepted
                          ? "Appointment accepted"
                          : message.text,
                    ),
                  ),

                  if (!isMe && isPending) // doctor side only
                    Row(
                      children: [
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextButton(
                              onPressed: () {
                                ChatService().acceptAppointment(
                                  chatId: chatId!,
                                  messageId: messageId!,
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Accept"),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(5.0),
                            child: TextButton(
                              onPressed: () {
                                ChatService().rejectAppointment(
                                  chatId: chatId!,
                                  messageId: messageId!,
                                );
                              },
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.red,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text("Reject"),
                            ),
                          ),
                        ),
                      ],
                    ),

                  // ---------- Patient cancel ----------
                  if (isMe && isPending && onCancel != null)
                    TextButton(
                      onPressed: onCancel,
                      child: const Text(
                        "Cancel Request",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),

                  // ---------- Status bar ----------
                  Container(
                    padding: const EdgeInsets.all(10),
                    color: Colors.black,
                    child: Text(
                      status?.toUpperCase() ?? "PENDING",
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.yellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }


    return Align(
      alignment: alignment,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isMe ? const Color(0xFFDCF8C6) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment:
          isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Text(
              message.text,
              style: const TextStyle(fontSize: 15),
            ),
            const SizedBox(height: 4),
            Text(
              message.time,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}