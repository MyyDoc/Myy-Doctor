part of 'notification_cubit.dart';

abstract class NotificationState {
  const NotificationState();
}

class NotificationInitial extends NotificationState {}

class NotificationLoading extends NotificationState {}

class NotificationEmpty extends NotificationState {}

class NotificationLoaded extends NotificationState {
  final List<AppNotificationModel> notifications;
  const NotificationLoaded(this.notifications);
}

class NotificationError extends NotificationState {
  final String message;
  const NotificationError(this.message);
}