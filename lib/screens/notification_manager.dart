import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationManager {
  static const platform = MethodChannel('com.example.app/notification');
  // ignore: constant_identifier_names
  static const String SELECTED_CONTACTS_KEY = 'selected_contacts';

  static Future<List<String>> getSelectedContactNumbers() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(SELECTED_CONTACTS_KEY) ?? [];
  }

  static Future<void> saveSelectedContacts(List<String> phoneNumbers) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(SELECTED_CONTACTS_KEY, phoneNumbers);
    await updateNotificationSettings(phoneNumbers);
  }

  static Future<void> updateNotificationSettings(List<String> allowedNumbers) async {
    try {
      await platform.invokeMethod('updateNotificationSettings', {
        'allowedNumbers': allowedNumbers,
      });
    } catch (e) {
      print('Failed to update notification settings: $e');
    }
  }

  static Future<bool> isContactAllowed(String phoneNumber) async {
    final allowedNumbers = await getSelectedContactNumbers();
    String cleanNumber = phoneNumber.replaceAll(RegExp(r'[^\d+]'), '');
    return allowedNumbers.contains(cleanNumber);
  }

  static Future<void> clearSelectedContacts() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(SELECTED_CONTACTS_KEY);
    await updateNotificationSettings([]);
  }
}