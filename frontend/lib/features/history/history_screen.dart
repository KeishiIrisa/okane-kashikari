import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:intl/intl.dart';

import '../../data/api_service.dart';
import '../../data/models.dart';
import '../authless_device/device_id_provider.dart';

final historyListProvider = FutureProvider<List<TransactionItem>>((ref) async {
  final dio = await ref.watch(apiClientProvider.future);
  final api = ApiService(dio);
  // status: 'paid' のものを取得
  return api.getTransactions(status: 'paid');
});

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(historyListProvider);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          '精算済み履歴',
          style: TextStyle(
            color: Color(0xFF1F1F1F),
            fontWeight: FontWeight.w900,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.chevronLeft),
          onPressed: () => context.pop(),
        ),
      ),
      body: RefreshIndicator(
        onRefresh: () async => ref.invalidate(historyListProvider),
        color: const Color(0xFF007AFF),
        child: historyAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: Color(0xFF007AFF)),
          ),
          error: (e, _) => Center(child: Text('エラー: $e')),
          data: (list) {
            if (list.isEmpty) {
              return ListView( // Use ListView to make RefreshIndicator work
                physics: const AlwaysScrollableScrollPhysics(),
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.3),
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(LucideIcons.history, size: 48, color: Colors.grey.shade200),
                        const SizedBox(height: 16),
                        Text(
                          '履歴はありません',
                          style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }
            return ListView.builder(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 40),
              itemCount: list.length,
              itemBuilder: (context, i) {
                final t = list[i];
                final isLent = t.direction == 'LENT';
                final accentColor = isLent ? const Color(0xFF007AFF) : const Color(0xFFEF4444);
                return _HistoryTile(transaction: t, accentColor: accentColor);
              },
            );
          },
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.transaction, required this.accentColor});

  final TransactionItem transaction;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final isLent = transaction.direction == 'LENT';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: ShadCard(
        padding: EdgeInsets.zero,
        radius: const BorderRadius.all(Radius.circular(24)),
        border: ShadBorder.all(color: const Color(0xFFF0F0F0), width: 1),
        backgroundColor: Colors.white,
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          leading: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              isLent ? LucideIcons.arrowUpRight : LucideIcons.arrowDownLeft,
              color: accentColor,
              size: 20,
            ),
          ),
          title: Text(
            transaction.contactName,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
          ),
          subtitle: Text(
            [
              if (transaction.purpose.isNotEmpty) transaction.purpose,
              if (transaction.dueDate != null && transaction.dueDate!.isNotEmpty)
                _formatDate(transaction.dueDate!)
              else
                '期日なし'
            ].join(' · '),
            style: const TextStyle(color: Color(0xFF737373), fontSize: 13, fontWeight: FontWeight.w500),
          ),
          trailing: Text(
            '¥${NumberFormat('#,###').format(transaction.amount)}',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: accentColor.withValues(alpha: 0.6),
              letterSpacing: -0.5,
              decoration: TextDecoration.lineThrough,
            ),
          ),
        ),
      ),
    );
  }

  static String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return DateFormat('M月d日').format(d);
    } catch (_) {
      return iso;
    }
  }
}
