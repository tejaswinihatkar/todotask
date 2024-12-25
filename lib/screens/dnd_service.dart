import 'package:flutter/services.dart';

class DNDService {
  static const platform = MethodChannel('com.example.app/dnd');

  static Future<bool> requestDNDAccess() async {
    try {
      final bool hasAccess = await platform.invokeMethod('requestDNDAccess');
      return hasAccess;
    } catch (e) {
      print('Error requesting DND access: $e');
      return false;
    }
  }

  static Future<bool> setDNDMode({
    required bool enabled,
    required List<String> allowedContacts,
    required List<String> allowedApps,
  }) async {
    try {
      final bool success = await platform.invokeMethod('setDNDMode', {
        'enabled': enabled,
        'allowedContacts': allowedContacts,
        'allowedApps': allowedApps,
      });
      return success;
    } catch (e) {
      print('Error setting DND mode: $e');
      return false;
    }
  }

  // Other methods remain unchanged...
}