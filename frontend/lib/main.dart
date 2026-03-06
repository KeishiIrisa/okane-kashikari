import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

import 'app.dart';
import 'features/authless_device/device_id_provider.dart';
import 'features/notifications/push_notifications.dart';
import 'core/flavor_config.dart';

Future<void> initializeApp(FlavorConfig config) async {
  WidgetsFlutterBinding.ensureInitialized();
  
  try {
    await Firebase.initializeApp();
  } catch (_) {
    // ローカル環境など Firebase 未設定時はスキップ
  }

  runApp(
    ProviderScope(
      child: OkaneKashikariApp(title: config.appTitle),
    ),
  );
}

class OkaneKashikariApp extends ConsumerWidget {
  final String title;
  const OkaneKashikariApp({super.key, required this.title});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(deviceIdProvider, (previous, next) async {
      if (next is AsyncData && Firebase.apps.isNotEmpty) {
        await initPushNotifications(ref);
      }
    });

    final deviceIdAsync = ref.watch(deviceIdProvider);
    return deviceIdAsync.when(
      loading: () => ShadApp(
        title: title,
        home: const Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(color: Color(0xFF007AFF)),
                SizedBox(height: 16),
                Text('準備中...', style: TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
          ),
        ),
      ),
      error: (e, _) => ShadApp(
        title: title,
        home: Scaffold(
          body: Center(child: Text('エラー: $e')),
        ),
      ),
      data: (_) => const App(),
    );
  }
}
