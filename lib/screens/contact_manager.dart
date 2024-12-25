import 'package:flutter/services.dart';

class ContactManager {
  // Define the MethodChannel
  static const platform = MethodChannel('com.example.contacts/silence');

  /// Sends the list of selected contacts to the native Android platform.
  ///
  /// The `selectedPhoneNumbers` parameter is a list of phone numbers for contacts
  /// that should remain unmuted during Focus Mode.
  static Future<void> muteUnselectedContacts(List<String> selectedPhoneNumbers) async {
    try {
      // Invoke the native method with the list of selected phone numbers
      await platform.invokeMethod('muteUnselectedContacts', {
        'selectedPhoneNumbers': selectedPhoneNumbers,
      });
    } on PlatformException catch (e) {
      // Handle any errors from the native side
      // ignore: avoid_print
      print("Failed to mute contacts: '${e.message}'.");
    }
  }

  /// Optional: Restore all contacts to normal state when disabling Focus Mode.
  static Future<void> disableFocusMode() async {
    try {
      // Notify the native side to disable Focus Mode
      await platform.invokeMethod('disableFocusMode');
    } on PlatformException catch (e) {
      // Handle any errors from the native side
      print("Failed to disable Focus Mode: '${e.message}'.");
    }
  }
}
