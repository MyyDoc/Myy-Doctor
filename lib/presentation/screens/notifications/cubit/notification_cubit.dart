import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myydoctor/data/notification/app_notification_model.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  StreamSubscription? _subscription;

  /// 🔒 In-memory cache: senderId → senderName
  final Map<String, String> _senderNameCache = {};

  void listenNotifications() {
    emit(NotificationLoading());

    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) {
      emit(const NotificationError("User not logged in"));
      return;
    }

    final ref = FirebaseDatabase.instance
        .ref('notifications/$uid')
        .orderByChild('createdAt');

    _subscription = ref.onValue.listen(
      (event) async {
        final data = event.snapshot.value;

        if (data == null) {
          emit(NotificationEmpty());
          return;
        }

        try {
          final map = Map<String, dynamic>.from(data as Map);

          final notifications =
              map.entries
                  .map(
                    (e) => AppNotificationModel.fromMap(
                      e.key,
                      Map<String, dynamic>.from(e.value),
                    ),
                  )
                  .toList();

          notifications.sort((a, b) {
            final aTime = a.createdAt;
            final bTime = b.createdAt;
            return bTime.compareTo(aTime); // newest first
          });

          // 🔽 Fetch only missing sender names
          await _fetchMissingSenderNames(notifications);

          emit(
            NotificationLoaded(
              notifications,
              Map<String, String>.from(_senderNameCache),
            ),
          );
        } catch (e) {
          emit(const NotificationError("Failed to parse notifications"));
        }
      },
      onError: (error) {
        emit(NotificationError(error.toString()));
      },
    );
  }

  /// 🔁 Fetch ONLY what is missing, ONCE
  Future<void> _fetchMissingSenderNames(
    List<AppNotificationModel> notifications,
  ) async {
    final firestore = FirebaseFirestore.instance;

    // unique senderIds from notifications
    final senderIds = notifications.map((n) => n.senderId).toSet();

    for (final senderId in senderIds) {
      // already cached → skip
      if (_senderNameCache.containsKey(senderId)) continue;

      try {
        final doc = await firestore.collection('users').doc(senderId).get();

        if (doc.exists) {
          final data = doc.data();
          final name = data?['fullName'] as String?;

          if (name != null) {
            _senderNameCache[senderId] = name;
          }
        }
      } catch (_) {
        // silent fail → UI fallback handles it
      }
    }
  }

  Future<void> markAsRead(String notificationId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return;

    await FirebaseDatabase.instance
        .ref('notifications/$uid/$notificationId/read')
        .set(true);
  }

  @override
  Future<void> close() {
    _subscription?.cancel();
    return super.close();
  }
}
