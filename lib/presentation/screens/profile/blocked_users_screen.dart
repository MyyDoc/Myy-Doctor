import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class BlockedUsersScreen extends StatelessWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser!.uid;

    final blockedRef =
    FirebaseDatabase.instance.ref('users/$currentUid/blockedUsers');

    return Scaffold(
      appBar: AppBar(
        title: const Text("Blocked Users"),
        centerTitle: true,
      ),
      body: StreamBuilder(
        stream: blockedRef.onValue,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.snapshot.value;

          if (data == null) {
            return const Center(child: Text("No blocked users"));
          }

          final Map<dynamic, dynamic> blockedMap =
          data as Map<dynamic, dynamic>;

          final blockedIds = blockedMap.keys.cast<String>().toList();

          return ListView.builder(
            itemCount: blockedIds.length,
            itemBuilder: (context, index) {
              final userId = blockedIds[index];

              return FutureBuilder(
                future: FirebaseDatabase.instance
                    .ref('users/$userId')
                    .get(),
                builder: (context, userSnap) {
                  if (!userSnap.hasData) {
                    return const ListTile(title: Text("Loading..."));
                  }

                  String name = "Unknown";
                  String? imageUrl;

                  if (userSnap.data!.exists &&
                      userSnap.data!.value is Map) {
                    final userData =
                    userSnap.data!.value as Map<dynamic, dynamic>;
                    name = userData['username'] ?? "Unknown";
                    imageUrl = userData['profileImageUrl'];
                  }

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage:
                      imageUrl != null ? NetworkImage(imageUrl) : null,
                      child: imageUrl == null
                          ? const Icon(Icons.person)
                          : null,
                    ),
                    title: Text(name),
                    trailing: TextButton(
                      onPressed: () async {
                        final confirm = await showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: const Text("Unblock User"),
                            content: const Text("Are you sure you want to unblock this user?"),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text("Cancel"),
                              ),
                              ElevatedButton(
                                onPressed: () => Navigator.pop(context, true),
                                child: const Text("Unblock"),
                              ),
                            ],
                          ),
                        );

                        if (confirm == true) {
                          bool result = await _unblockUser(currentUid, userId);

                          if (result) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text("User unblocked")),
                            );
                          }
                        }
                      },
                      child: const Text(
                        "Unblock",
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Future<bool> _unblockUser(String currentUid, String targetUserId) async {
    try {
      final ref = FirebaseDatabase.instance
          .ref('users/$currentUid/blockedUsers/$targetUserId');

      await ref.remove();
      return true;
    } catch (e) {
      return false;
    }
  }
}