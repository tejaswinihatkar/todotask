import 'package:flutter/foundation.dart';

enum ContactType {
  handle,
  notHandle;

  bool get isHandled => this == ContactType.handle;
  
  static ContactType fromString(String value) {
    return ContactType.values.firstWhere(
      (type) => type.toString() == 'ContactType.$value',
      orElse: () => ContactType.handle,
    );
  }

  @override
  String toString() {
    return describeEnum(this);
  }
}