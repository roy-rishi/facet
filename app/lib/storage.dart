import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

const storage = FlutterSecureStorage();
late SharedPreferences prefs;
// TODO: hard-code storage key names

Future<String> getAccessToken() async {
  String? token = await storage.read(key: "access_token");
  return token ?? "";
}

void setAccessToken(String newToken) async {
  await storage.write(key: "access_token", value: newToken);
}

void initializeSharedPrefs() async {
  prefs = await SharedPreferences.getInstance();
}
