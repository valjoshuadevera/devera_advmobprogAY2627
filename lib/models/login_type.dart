// Enhancement 2: Separates DummyJSON authentication from Firebase authentication.
enum LoginType { dummyJson, firebase }

extension LoginTypeExtension on LoginType {
  String get storageValue {
    switch (this) {
      case LoginType.dummyJson:
        return 'dummyJson';
      case LoginType.firebase:
        return 'firebase';
    }
  }

  String get displayName {
    switch (this) {
      case LoginType.dummyJson:
        return 'DummyJSON';
      case LoginType.firebase:
        return 'Firebase';
    }
  }

  static LoginType fromStorageValue(String value) {
    return value == LoginType.firebase.storageValue
        ? LoginType.firebase
        : LoginType.dummyJson;
  }
}
