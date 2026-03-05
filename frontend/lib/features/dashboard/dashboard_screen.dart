import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../data/api_service.dart';
import '../../data/models.dart';
import '../authless_device/device_id_provider.dart';

final summaryProvider = FutureProvider<SummaryData>((ref) async {
  final dio = await ref.watch(apiClientProvider.future);
  final api = ApiService(dio);
  return api.getSummary();
});

final lentListProvider = FutureProvider<List<TransactionItem>>((ref) async {
  final dio = await ref.watch(apiClientProvider.future);
  final api = ApiService(dio);
  return api.getTransactions(direction: 'LENT', status: 'unpaid');
});

final borrowedListProvider = FutureProvider<List<TransactionItem>>((ref) async {
  final dio = await ref.watch(apiClientProvider.future);
  final api = ApiService(dio);
  return api.getTransactions(direction: 'BORROWED', status: 'unpaid');
});

/// 通知などから「借りリスト」タブを開きたい時に使う
final selectedDirectionProvider = StateProvider<String>((ref) => 'LENT');

class DashboardScreen extends ConsumerStatefulWidget {
  const DashboardScreen({super.key});

  @override
  ConsumerState<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends ConsumerState<DashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedDirection = ref.watch(selectedDirectionProvider);
    if (selectedDirection == 'BORROWED' && _tabController.index != 1) {
      _tabController.index = 1;
    } else if (selectedDirection == 'LENT' && _tabController.index != 0) {
      _tabController.index = 0;
    }

    final summaryAsync = ref.watch(summaryProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('お金貸し借り'),
        actions: [
          IconButton(icon: const Icon(Icons.settings), onPressed: () => context.push('/settings')),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: '貸しリスト'),
            Tab(text: '借りリスト'),
          ],
        ),
      ),
      body: summaryAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('エラー: $e')),
        data: (summary) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: _SummaryCard(
                        title: '貸している合計（＋）',
                        amount: summary.totalLentUnpaid,
                        color: const Color(0xFF1976D2),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _SummaryCard(
                        title: '借りている合計（ー）',
                        amount: summary.totalBorrowedUnpaid,
                        color: const Color(0xFFE65100),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _TransactionList(direction: 'LENT'),
                    _TransactionList(direction: 'BORROWED'),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/transaction/new'),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({required this.title, required this.amount, required this.color});

  final String title;
  final int amount;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      color: color.withOpacity(0.12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(title, style: TextStyle(fontSize: 12, color: color.withOpacity(0.9))),
            const SizedBox(height: 8),
            Text(
              '¥${NumberFormat('#,###').format(amount)}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: color),
            ),
          ],
        ),
      ),
    );
  }
}

class _TransactionList extends ConsumerWidget {
  const _TransactionList({required this.direction});

  final String direction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final provider = direction == 'LENT' ? lentListProvider : borrowedListProvider;
    final async = ref.watch(provider);

    return async.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('エラー: $e')),
      data: (list) {
        if (list.isEmpty) {
          return Center(child: Text('$direction の未精算はありません'));
        }
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final t = list[i];
            return _TransactionTile(transaction: t);
          },
        );
      },
    );
  }
}

class _TransactionTile extends ConsumerWidget {
  const _TransactionTile({required this.transaction});

  final TransactionItem transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isLent = transaction.direction == 'LENT';
    final dueStr = transaction.dueDate != null && transaction.dueDate!.isNotEmpty
        ? _formatDate(transaction.dueDate!)
        : '期日なし';

    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        title: Text(transaction.contactName),
        subtitle: Text('${transaction.purpose} · $dueStr'),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '¥${NumberFormat('#,###').format(transaction.amount)}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isLent ? const Color(0xFF1976D2) : const Color(0xFFE65100),
              ),
            ),
            PopupMenuButton<String>(
              onSelected: (value) async {
                if (value == 'edit') {
                  context.push('/transaction/${transaction.id}/edit');
                } else if (value == 'paid') {
                  final dio = await ref.read(apiClientProvider.future);
                  final api = ApiService(dio);
                  await api.markTransactionPaid(transaction.id);
                  ref.invalidate(summaryProvider);
                  ref.invalidate(lentListProvider);
                  ref.invalidate(borrowedListProvider);
                  if (context.mounted) context.go('/');
                } else if (value == 'reminder' && isLent) {
                  context.push('/transaction/${transaction.id}/reminder');
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: Text('編集')),
                const PopupMenuItem(value: 'paid', child: Text('精算済みにする')),
                if (isLent) const PopupMenuItem(value: 'reminder', child: Text('催促')),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static String _formatDate(String iso) {
    try {
      final d = DateTime.parse(iso);
      return DateFormat('M/d').format(d);
    } catch (_) {
      return iso;
    }
  }
}
