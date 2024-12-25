import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService instance = NotificationService._();
  NotificationService._();

  final _notificationsPlugin = FlutterLocalNotificationsPlugin();
  bool _notificationsEnabled = true;

  Future<void> disableNotifications() async {
    _notificationsEnabled = false;
    await _notificationsPlugin.cancelAll();
  }

  Future<void> enableNotifications() async {
    _notificationsEnabled = true;
  }

  bool get isEnabled => _notificationsEnabled;
}