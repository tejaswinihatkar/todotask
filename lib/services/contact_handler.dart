import '../models/contact_type.dart';
import 'notification_service.dart';
import 'dart:async';

class ContactHandler {
  static final Map<String, ContactType> _contactTypes = {};
  static final Map<String, Timer> _temporaryUnmutes = {};
  static const Duration _unmuteDuration = Duration(seconds: 30);

  static void classifyContact(String phoneNumber, ContactType type) {
    _contactTypes[phoneNumber] = type;
    _handleNotificationState(phoneNumber);
  }

  static Future<void> _handleNotificationState(String phoneNumber) async {
    if (_contactTypes[phoneNumber] == ContactType.handle) {
      _startTemporaryUnmute(phoneNumber);
    }
  }

  static void _startTemporaryUnmute(String phoneNumber) {
    _temporaryUnmutes[phoneNumber]?.cancel();
    _temporaryUnmutes[phoneNumber] = Timer(_unmuteDuration, () {
      NotificationService.instance.disableNotifications();
      _temporaryUnmutes.remove(phoneNumber);
    });
    NotificationService.instance.enableNotifications();
  }

  static bool shouldAllowNotification(String phoneNumber) {
    return _contactTypes[phoneNumber] == ContactType.handle || 
           _temporaryUnmutes.containsKey(phoneNumber);
  }
}