import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:myydoctor/data/notification/app_notification_model.dart';

part 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  NotificationCubit() : super(NotificationInitial());

  StreamSubscription? _subscription;

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
      (event) {
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

          notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));

          emit(NotificationLoaded(notifications));
        } catch (e) {
          emit(const NotificationError("Failed to parse notifications"));
        }
      },
      onError: (error) {
        emit(NotificationError(error.toString()));
      },
    );
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
