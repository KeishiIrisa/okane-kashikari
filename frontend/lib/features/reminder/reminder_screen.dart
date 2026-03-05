import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import '../../data/api_service.dart';
import '../../data/models.dart';
import '../authless_device/device_id_provider.dart';

final transactionDetailProvider = FutureProvider.family<TransactionItem?, String>((ref, id) async {
  final dio = await ref.watch(apiClientProvider.future);
  return ApiService(dio).getTransaction(id);
});

final defaultReminderMsgProvider = FutureProvider<String>((ref) async {
  final dio = await ref.watch(apiClientProvider.future);
  return ApiService(dio).getDefaultReminderMsg();
});

class ReminderScreen extends ConsumerStatefulWidget {
  const ReminderScreen({super.key, required this.transactionId});

  final String transactionId;

  @override
  ConsumerState<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends ConsumerState<ReminderScreen> {
  final _messageController = TextEditingController();
  bool _initialized = false;

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final txAsync = ref.watch(transactionDetailProvider(widget.transactionId));
    final defaultMsgAsync = ref.watch(defaultReminderMsgProvider);
    const accentColor = Color(0xFF007AFF); // 貸しベースの青

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('催促メッセージを送る', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      body: txAsync.when(
        loading: () => const Center(child: CircularProgressIndicator(color: accentColor)),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (tx) {
          if (tx == null) return const Center(child: Text('取引が見つかりません'));
          final defaultMsg = defaultMsgAsync.valueOrNull ?? '';
          if (!_initialized && defaultMsgAsync.hasValue) {
            _initialized = true;
            final body = defaultMsg.isNotEmpty ? defaultMsg : '${tx.contactName}さん、${tx.purpose}でお貸しした¥${tx.amount}の件、お返しいただけますか？';
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_messageController.text.isEmpty) _messageController.text = body;
            });
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: accentColor.withValues(alpha: 0.1),
                      child: const Icon(LucideIcons.user, color: accentColor, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      '${tx.contactName}さんへのメッセージ',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                const Text(
                  'メッセージ内容（編集できます）',
                  style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF737373), fontSize: 13),
                ),
                const SizedBox(height: 12),
                ShadInput(
                  controller: _messageController,
                  maxLines: 6,
                  placeholder: const Text('催促文を入力'),
                  padding: const EdgeInsets.all(16),
                ),
                const Spacer(),
                const Text(
                  '外部アプリで送信します',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF737373), fontSize: 12),
                ),
                const SizedBox(height: 12),
                ShadButton(
                  onPressed: () => _openLine(_messageController.text),
                  backgroundColor: const Color(0xFF06C755), // LINE Color
                  pressedBackgroundColor: const Color(0xFF05a347), // 少し暗い緑
                  size: ShadButtonSize.lg,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset(
                        'assets/icons/LINE_Brand_icon.png',
                        width: 24,
                        height: 24,
                      ),
                      const SizedBox(width: 8),
                      const Text('LINE で送る', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openLine(String message) async {
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('https://line.me/R/share?text=$encoded');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('LINE を開けませんでした')),
        );
      }
    }
  }

  Future<void> _shareMessage(String message) async {
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('sms:?&body=$encoded');
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('アプリを開けませんでした')),
        );
      }
    }
  }
}
