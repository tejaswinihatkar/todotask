import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import './contact_handler.dart';
import './notification_service.dart';

class CallHandler {
  bool _isCallActive = false;
  String? _currentCallNumber;
  final _notificationPlugin = FlutterLocalNotificationsPlugin();

  Future<void> handleIncomingCall(String phoneNumber) async {
    _isCallActive = true;
    _currentCallNumber = phoneNumber;
    
    if (!ContactHandler.shouldAllowNotification(phoneNumber)) {
      await _notificationPlugin.cancelAll();
      await NotificationService.instance.disableNotifications();
    }
  }

  bool shouldAllowNotification(String phoneNumber) {
    if (!_isCallActive) return true;
    return ContactHandler.shouldAllowNotification(phoneNumber);
  }

  Future<void> handleCallEnded() async {
    _isCallActive = false;
    _currentCallNumber = null;
    await NotificationService.instance.enableNotifications();
  }
}