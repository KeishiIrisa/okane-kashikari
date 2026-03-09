import 'package:dio/dio.dart';
import 'flavor_config.dart';

Dio createDio({String? deviceId}) {
  final apiBaseUrl = FlavorConfig.instance.apiBaseUrl;
  
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
