import 'package:flutter/material.dart';
import 'package:myydoctor/presentation/screens/chat/chat_screen.dart';
import 'package:myydoctor/presentation/widgets/chat/call_list_widget.dart';

class ChatTileWidget extends StatelessWidget {
  final List<ChatItem> chats = [
    ChatItem('Dr.John Doe', 'Hey, how are you doing?', '2:30 PM', true),
    ChatItem('Jane Smith', 'Can we meet tomorrow?', '1:45 PM', false),
    ChatItem('Dr.Mike Johnson', 'Thanks for the help!', '12:20 PM', false),
    ChatItem('Sarah Wilson', 'See you at the conference', '11:30 AM', true),
    ChatItem('David Brown', 'The project looks great', '10:15 AM', false),
    ChatItem('Dr.Emily Davis', 'Happy birthday! 🎉', 'Yesterday', true),
    ChatItem('Alex Miller', 'Are you free this weekend?', 'Yesterday', false),
    ChatItem('Lisa Garcia', 'Check out this article', 'Monday', false),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: chats.length,
      itemBuilder: (context, index) {
        final chat = chats[index];
        return ListTile(
          leading: CircleAvatar(
            radius: 30,
            backgroundColor: Colors.blue.shade100,
            child: Text(
              chat.name[0].toUpperCase(),
              style: TextStyle(
                color: Colors.blue.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            chat.name,
            style: TextStyle(
              color:
                  chat.name.startsWith("Dr") ? Color(0xFFD4AF37) : Colors.black,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          subtitle: Text(
            chat.message,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(color: Colors.black, fontSize: 14),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                chat.time,
                style: TextStyle(color: Colors.black, fontSize: 12),
              ),
              if (chat.hasUnread)
                Container(
                  margin: EdgeInsets.only(top: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    shape: BoxShape.circle,
                  ),
                ),
            ],
          ),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => ChatScreen()),
            );
          },
        );
      },
    );
  }
}
