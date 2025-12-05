import 'package:flutter/material.dart';
import 'package:myydoctor/data/notification/notification_model.dart';

class NotificationsScreen extends StatelessWidget {
  final List<NotificationItem> notifications = [
    NotificationItem(
      avatar: '⚡',
      name: 'Pikachu',
      message: 'wants to follow you',
      time: '10:30',
      buttonText: 'Accept',
      buttonColor: Colors.brown[300],
    ),
    NotificationItem(
      avatar: '🧙‍♂️',
      name: 'Dr. Rohith',
      message: 'followed you back',
      time: '12:30',
      buttonText: 'Unfollow',
      buttonColor: Colors.brown[300],
    ),
    NotificationItem(
      avatar: '🦋',
      name: 'Dr. Venus',
      message: 'started following you',
      time: '14:30',
      buttonText: 'Following',
      buttonColor: Colors.brown[300],
    ),
    NotificationItem(
      avatar: '💬',
      name: 'Dr. Rohith',
      message: 'Do you have consult free wednesday?',
      time: '15:30',
      hasNewBadge: true,
    ),
    NotificationItem(
      avatar: '🕒',
      name: 'Dr. Venus',
      message: 'booked an appointment',
      time: 'Yesterday',
      hasNewBadge: true,
    ),
    NotificationItem(
      avatar: '👨‍👩‍👧‍👦',
      name: 'Charizard',
      message: 'visited your profile 6 times',
      time: 'Yesterday',
    ),
    NotificationItem(
      avatar: '📤',
      name: 'Charizard',
      message: 'shared your post to 3 Instagram',
      time: 'Yesterday',
      socialIcon: Icons.camera_alt_outlined,
      socialIconColor: Colors.purple,
    ),
    NotificationItem(
      avatar: '📤',
      name: 'Pikachu',
      message: 'shared your post to 5 Whatsapp',
      time: 'Yesterday',
      socialIcon: Icons.chat,
      socialIconColor: Colors.green,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Color(0xFF1F323C),
        elevation: 0,
        title: Text(
          'rahuljaicsam',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            color: Color(0xFF1F323C),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromARGB(255, 215, 176, 85),
                                Colors.white38,
                                Color.fromARGB(255, 215, 176, 85),
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                  borderRadius: BorderRadius.circular(25),
                ),
                child: TextField(
                  decoration: InputDecoration(
                    hintText: 'SEARCH NOTIFICATIONS',
                    hintStyle: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                    prefixIcon: Icon(
                      Icons.search,
                      color: Colors.grey[600],
                      size: 20,
                    ),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          // Notifications list
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(horizontal: 16),
              itemCount: notifications.length,
              separatorBuilder: (context, index) => SizedBox(height: 4),
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Container(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(30),
                        ),
                        child: Center(
                          child: Text(
                            notification.avatar,
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  notification.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color:
                                        notification.name.startsWith("Dr")
                                            ?  Color(0xFFD4AF37)
                                            : Colors.brown[700],
                                  ),
                                ),
                                if (notification.hasNewBadge) ...[
                                  SizedBox(width: 8),
                                  Container(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 2,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Text(
                                      'New',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ],
                            ),
                            SizedBox(height: 2),
                            Text(
                              notification.message,
                              style: TextStyle(
                                color: Colors.grey[700],
                                fontSize: 15,
                              ),
                            ),
                            SizedBox(height: 2),
                            Text(
                              notification.time,
                              style: TextStyle(
                                color: Colors.grey[500],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      // Action button or social icon
                      if (notification.socialIcon != null) ...[
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: notification.socialIconColor?.withOpacity(
                              0.1,
                            ),
                            borderRadius: BorderRadius.circular(16),
                            border: Border.all(
                              color:
                                  notification.socialIconColor ?? Colors.grey,
                              width: 1,
                            ),
                          ),
                          child: Icon(
                            notification.socialIcon,
                            color: notification.socialIconColor,
                            size: 16,
                          ),
                        ),
                      ] else if (notification.buttonText != null) ...[
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                Color.fromARGB(255, 215, 176, 85),
                                Colors.white38,
                                Color.fromARGB(255, 215, 176, 85),
                              ],
                              stops: [0.0, 0.5, 1.0],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            notification.buttonText!,
                            style: TextStyle(
                              color: Colors.brown,
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
