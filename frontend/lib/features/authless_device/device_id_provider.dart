import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/api_client.dart';
import '../../core/device_id_storage.dart';

final sharedPreferencesProvider = FutureProvider<SharedPreferences>((ref) async {
  return SharedPreferences.getInstance();
});

/// 端末ID。初回は生成して保存し、API に登録する。
final deviceIdProvider = FutureProvider<String>((ref) async {
  final prefs = await ref.watch(sharedPreferencesProvider.future);
  final deviceId = await getOrCreateDeviceId(prefs);
  final dio = createDio();
  try {
    await dio.post('/devices/register', data: {'device_id': deviceId});
  } catch (_) {
    // オフライン等では登録失敗してもローカルIDは使う
  }
  return deviceId;
});

/// deviceId が確定した後の Dio クライアント（X-Device-Id 付き）
final apiClientProvider = FutureProvider<Dio>((ref) async {
  final deviceId = await ref.watch(deviceIdProvider.future);
  return createDio(deviceId: deviceId);
});
