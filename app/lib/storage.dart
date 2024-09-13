import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const storage = FlutterSecureStorage();
const accessTokenKey = "access_token";

Future<String> getAccessToken() async {
  String? token = await storage.read(key: accessTokenKey);
  return token ?? "";
}

void setAccessToken(String newToken) async {
  await storage.write(key: accessTokenKey, value: newToken);
}
