import 'package:dio/dio.dart';

/// API ベースURL。本番では環境変数や Flavors で切り替え。
///
/// Android Emulator からホストの `localhost` にアクセスする場合は `http://10.0.2.2:8080` を指定する。
/// 例: `flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080`
const String apiBaseUrl = String.fromEnvironment(
  'API_BASE_URL',
  defaultValue: 'http://localhost:8080',
);

Dio createDio({String? deviceId}) {
  final dio = Dio(BaseOptions(
    baseUrl: '$apiBaseUrl/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  ));
  if (deviceId != null && deviceId.isNotEmpty) {
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) {
        options.headers['X-Device-Id'] = deviceId;
        return handler.next(options);
      },
    ));
  }
  return dio;
}
