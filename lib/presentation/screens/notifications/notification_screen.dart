import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:myydoctor/data/notification/app_notification_model.dart';
import 'package:myydoctor/presentation/screens/chat/chat_screen.dart';
import 'package:myydoctor/presentation/screens/notifications/cubit/notification_cubit.dart';

import '../../../core/loader/loader.dart';

class NotificationsScreen extends StatelessWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NotificationCubit()..listenNotifications(),
      child: const _NotificationsView(),
    );
  }
}

class _NotificationsView extends StatelessWidget {
  const _NotificationsView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color(0xFF1F323C),
        elevation: 0,
        centerTitle: true,
        title: const Text(
          'Notifications',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state is NotificationError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.redAccent,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading ||
              state is NotificationInitial) {
            return const Center(child: MyyDocLoader());
          }

          if (state is NotificationEmpty) {
            return const Center(
              child: Text(
                "No notifications",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
            );
          }

          if (state is NotificationLoaded) {
            return _NotificationList(
              notifications: state.notifications,
              senderNames: state.senderNames,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final List<AppNotificationModel> notifications;
  final Map<String, String> senderNames;

  const _NotificationList({
    required this.notifications,
    required this.senderNames,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final notification = notifications[index];
        return _NotificationTile(
          notification: notification,
          senderName:
              senderNames[notification.senderId] ?? "Someone",
        );
      },
    );
  }
}

class _NotificationTile extends StatelessWidget {
  final AppNotificationModel notification;
  final String senderName;

  const _NotificationTile({
    required this.notification,
    required this.senderName,
  });

  @override
  Widget build(BuildContext context) {
    final bool isUnread = !notification.read;

    return GestureDetector(
      onTap: () {
        context
            .read<NotificationCubit>()
            .markAsRead(notification.id);
        
        if(notification.type == "appointment_request") Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(chatId: notification.entityId ?? "", isDoctor: false),));
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: Colors.grey[200],
              child: Icon(
                _iconForType(notification.type),
                color: const Color(0xFFD4AF37),
              ),
            ),
            const SizedBox(width: 12),

            /// TEXT CONTENT
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    crossAxisAlignment: WrapCrossAlignment.center,
                    spacing: 6,
                    runSpacing: 4,
                    children: [
                      Text(
                        senderName,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        _titleForType(notification.type),
                        style: const TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      if (isUnread)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.red,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Text(
                            "New",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    notification.text,
                    softWrap: true,
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForType(String type) {
    switch (type) {
      case "follow":
        return Icons.person_add_alt;
      case "appointment_request":
        return Icons.calendar_month;
      case "appointment_accepted":
        return Icons.check_circle;
      case "appointment_rejected":
        return Icons.cancel;
      case "message":
        return Icons.chat;
      default:
        return Icons.notifications;
    }
  }

  String _titleForType(String type) {
    switch (type) {
      case "follow":
        return "started following you";
      case "appointment_request":
        return "requested an appointment";
      case "appointment_accepted":
        return "accepted your appointment";
      case "appointment_rejected":
        return "rejected your appointment";
      case "message":
        return "sent you a message";
      default:
        return "sent a notification";
    }
  }
}
