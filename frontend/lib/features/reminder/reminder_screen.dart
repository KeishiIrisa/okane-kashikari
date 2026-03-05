import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

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

    return Scaffold(
      appBar: AppBar(title: const Text('催促メッセージ')),
      body: txAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${tx.contactName}さんへのメッセージ（編集可）',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _messageController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    hintText: '催促文を入力',
                  ),
                ),
                const SizedBox(height: 24),
                FilledButton.icon(
                  onPressed: () => _openLine(_messageController.text),
                  icon: const Icon(Icons.chat),
                  label: const Text('LINE で送る'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _openLine(String message) async {
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('https://line.me/R/msg/text/?$encoded');
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
}
