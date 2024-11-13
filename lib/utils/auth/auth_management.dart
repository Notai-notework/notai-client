import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthManagement {
  Future<bool> isLoggedIn() async {
    final storage = FlutterSecureStorage();
    return storage.read(key: "isLoggedIn").then((res) => res == "true");
  }
}
