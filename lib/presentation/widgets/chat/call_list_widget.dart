import 'package:flutter/material.dart';

class CallsScreen extends StatelessWidget {
  final List<CallItem> calls = [
    CallItem('John Doe', CallType.incoming, '2:30 PM', true),
    CallItem('Jane Smith', CallType.outgoing, '1:45 PM', false),
    CallItem('Mike Johnson', CallType.missed, '12:20 PM', false),
    CallItem('Sarah Wilson', CallType.incoming, '11:30 AM', true),
    CallItem('David Brown', CallType.outgoing, '10:15 AM', true),
    CallItem('Emily Davis', CallType.incoming, 'Yesterday', true),
    CallItem('Alex Miller', CallType.missed, 'Yesterday', false),
    CallItem('Lisa Garcia', CallType.outgoing, 'Monday', true),
  ];

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: calls.length,
      itemBuilder: (context, index) {
        final call = calls[index];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.green.shade100,
            child: Text(
              call.name[0].toUpperCase(),
              style: TextStyle(
                color: Colors.green.shade800,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          title: Text(
            call.name,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
              color: call.type == CallType.missed ? Colors.red : Colors.white,
            ),
          ),
          subtitle: Row(
            children: [
              Icon(
                _getCallIcon(call.type),
                size: 16,
                color: _getCallIconColor(call.type),
              ),
              SizedBox(width: 4),
              Text(
                call.time,
                style: TextStyle(
                  color: Colors.grey.shade300,
                  fontSize: 14,
                ),
              ),
            ],
          ),
          trailing: IconButton(
            icon: Icon(
              Icons.call,
              color: Colors.green,
            ),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Calling ${call.name}')),
              );
            },
          ),
          onTap: () {
            // Show call details
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Call details for ${call.name}')),
            );
          },
        );
      },
    );
  }

    IconData _getCallIcon(CallType type) {
    switch (type) {
      case CallType.incoming:
        return Icons.call_received;
      case CallType.outgoing:
        return Icons.call_made;
      case CallType.missed:
        return Icons.call_received;
    }
  }

  Color _getCallIconColor(CallType type) {
    switch (type) {
      case CallType.incoming:
        return Colors.green;
      case CallType.outgoing:
        return Colors.blue;
      case CallType.missed:
        return Colors.red;
    }
  }
}

class ChatItem {
  final String name;
  final String message;
  final String time;
  final bool hasUnread;

  ChatItem(this.name, this.message, this.time, this.hasUnread);
}

class CallItem {
  final String name;
  final CallType type;
  final String time;
  final bool wasAnswered;

  CallItem(this.name, this.type, this.time, this.wasAnswered);
}

enum CallType {
  incoming,
  outgoing,
  missed,
}