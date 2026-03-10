import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/api_service.dart';
import '../../router.dart';
import '../authless_device/device_id_provider.dart';
import '../dashboard/dashboard_screen.dart';

/// 通知タップ時の処理など、プッシュ通知周りの初期化を行う。
Future<void> initPushNotifications(WidgetRef ref) async {
  if (Firebase.apps.isEmpty) {
    // Firebase が初期化されていない環境（ローカル等）では何もしない
    return;
  }
  final messaging = FirebaseMessaging.instance;

  // 権限リクエスト（主に iOS）
  await messaging.requestPermission();

  // デバイストークン登録
  final token = await messaging.getToken();
  if (token != null) {
    final dio = await ref.read(apiClientProvider.future);
    final api = ApiService(dio);
    final platform = Platform.isIOS ? 'ios' : 'android';
    await api.registerDeviceToken(token, platform: platform);
  }

  // アプリが終了状態から通知タップで起動された場合
  final initialMessage = await messaging.getInitialMessage();
  if (initialMessage != null) {
    await _handleNotificationTap(ref, initialMessage);
  }

  // バックグラウンド → フォアグラウンド
  FirebaseMessaging.onMessageOpenedApp.listen((message) {
    _handleNotificationTap(ref, message);
  });
}

Future<void> _handleNotificationTap(WidgetRef ref, RemoteMessage message) async {
  final data = message.data;
  final direction = data['direction'];
  final transactionId = data['transaction_id'];

  // LENT の場合は該当 transaction の LINE 催促画面へ遷移
  if (direction == 'LENT') {
    if (transactionId is String && transactionId.isNotEmpty) {
      goRouter.push('/transaction/$transactionId/reminder');
    }
    return;
  }

  // BORROWED などその他はアプリのダッシュボード画面へ遷移し、「借りリスト」タブを選択
  ref.read(selectedTabProvider.notifier).state = 'BORROWED';
  goRouter.go('/');
}

