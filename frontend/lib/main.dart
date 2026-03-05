import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'features/authless_device/device_id_provider.dart';
import 'features/notifications/push_notifications.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Firebase 設定(values.xml 等)がない環境でもクラッシュしないようにする
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // ローカル環境など Firebase 未設定時はスキップ
  }

  runApp(
    const ProviderScope(
      child: OkaneKashikariApp(),
    ),
  );
}

/// deviceId が確定してからダッシュボードを表示するラッパー
class OkaneKashikariApp extends ConsumerWidget {
  const OkaneKashikariApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // deviceId が確定し、かつ Firebase が初期化されている場合のみプッシュ通知初期化を行う
    ref.listen(deviceIdProvider, (previous, next) async {
      if (next is AsyncData && Firebase.apps.isNotEmpty) {
        await initPushNotifications(ref);
      }
    });

    final deviceIdAsync = ref.watch(deviceIdProvider);
    return deviceIdAsync.when(
      loading: () => MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(height: 16),
                Text('準備中...', style: Theme.of(context).textTheme.bodyLarge),
              ],
            ),
          ),
        ),
      ),
      error: (e, _) => MaterialApp(
        home: Scaffold(
          body: Center(child: Text('エラー: $e')),
        ),
      ),
      data: (_) => const App(),
    );
  }
}
