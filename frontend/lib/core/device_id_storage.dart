import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

const String _keyDeviceUserId = 'device_user_id';

Future<String> getOrCreateDeviceId(SharedPreferences prefs) async {
  final existing = prefs.getString(_keyDeviceUserId);
  if (existing != null && existing.isNotEmpty) return existing;
  const uuid = Uuid();
  final newId = uuid.v4();
  await prefs.setString(_keyDeviceUserId, newId);
  return newId;
}

String? getDeviceIdSync(SharedPreferences prefs) {
  return prefs.getString(_keyDeviceUserId);
}
