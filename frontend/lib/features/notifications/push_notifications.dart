import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // LENT の場合は LINE URL に飛ばす（アプリ内画面遷移ではなく外部リンク）
  if (direction == 'LENT') {
    final lineUrl = data['line_url'];
    if (lineUrl is String && lineUrl.isNotEmpty) {
      final uri = Uri.tryParse(lineUrl);
      if (uri != null) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      }
    }
    return;
  }

  // BORROWED などその他はアプリのダッシュボード画面へ遷移し、「借りリスト」タブを選択
  ref.read(selectedDirectionProvider.notifier).state = 'BORROWED';
  goRouter.go('/');
}

