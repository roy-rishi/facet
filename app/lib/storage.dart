import 'package:flutter_secure_storage/flutter_secure_storage.dart';

const _storage = FlutterSecureStorage();
const accessTokenKey = "access_token";

Future<String> getAccessToken() async {
  String? token = await _storage.read(key: accessTokenKey);
  return token ?? "";
}

void setAccessToken(String newToken) async {
  await _storage.write(key: accessTokenKey, value: newToken);
}
