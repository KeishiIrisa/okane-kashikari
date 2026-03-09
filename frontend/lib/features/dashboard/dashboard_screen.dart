import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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

final selectedTabProvider = StateProvider<String>((ref) => 'LENT');

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final summaryAsync = ref.watch(summaryProvider);
    final selectedTab = ref.watch(selectedTabProvider);
    
    // カラー設定
    const lentColor = Color(0xFF007AFF); // 貸し: 青
    const borrowedColor = Color(0xFFEF4444); // 借り: 赤

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // 白基調のヘッダー
          SliverAppBar(
            expandedHeight: 60,
            toolbarHeight: 60,
            floating: false,
            pinned: true,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            title: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.asset(
                    'assets/icons/app_icon.png',
                    width: 32,
                    height: 32,
                  ),
                ),
                const SizedBox(width: 10),
                const Text(
                  'お金の貸し借り',
                  style: TextStyle(
                    color: Color(0xFF1F1F1F),
                    fontWeight: FontWeight.w900,
                    fontSize: 18,
                    letterSpacing: -0.5,
                  ),
                ),
              ],
            ),
            actions: [
              ShadButton.ghost(
                onPressed: () => context.push('/history'),
                child: const Icon(LucideIcons.history, color: Color(0xFF1F1F1F), size: 22),
              ),
              Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ShadButton.ghost(
                  onPressed: () => context.push('/settings'),
                  child: const Icon(LucideIcons.settings, color: Color(0xFF1F1F1F), size: 22),
                ),
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: summaryAsync.when(
              loading: () => const Padding(
                padding: EdgeInsets.all(32),
                child: Center(child: CircularProgressIndicator(color: lentColor)),
              ),
              error: (e, _) => Center(child: Text('エラー: $e')),
              data: (summary) {
                return Column(
                  children: [
                    // サマリーカードセクション
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                      child: Row(
                        children: [
                          Expanded(
                            child: _SummaryCard(
                              title: '貸している',
                              amount: summary.totalLentUnpaid,
                              icon: LucideIcons.arrowUpRight,
                              color: lentColor,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _SummaryCard(
                              title: '借りている',
                              amount: summary.totalBorrowedUnpaid,
                              icon: LucideIcons.arrowDownLeft,
                              color: borrowedColor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // タブ切り替え（貸し＝青、借り＝赤）
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(100),
                        ),
                        padding: const EdgeInsets.all(4),
                        child: Row(
                          children: [
                            _TabButton(
                              label: '貸しリスト',
                              value: 'LENT',
                              isSelected: selectedTab == 'LENT',
                              activeColor: lentColor,
                              onPressed: () => ref.read(selectedTabProvider.notifier).state = 'LENT',
                            ),
                            _TabButton(
                              label: '借りリスト',
                              value: 'BORROWED',
                              isSelected: selectedTab == 'BORROWED',
                              activeColor: borrowedColor,
                              onPressed: () => ref.read(selectedTabProvider.notifier).state = 'BORROWED',
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),
                    _TransactionList(direction: selectedTab),
                  ],
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: SizedBox(
        width: 60,
        height: 60,
        child: ShadButton(
          padding: EdgeInsets.zero,
          onPressed: () => context.push('/transaction/new?direction=$selectedTab'),
          backgroundColor: selectedTab == 'LENT' ? lentColor : borrowedColor,
          decoration: ShadDecoration(
            border: ShadBorder(
              radius: BorderRadius.circular(30),
            ),
          ),
          child: const Icon(LucideIcons.plus, size: 32, color: Colors.white),
        ),
      ),
    );
  }
}

class _TabButton extends StatelessWidget {
  const _TabButton({
    required this.label,
    required this.value,
    required this.isSelected,
    required this.activeColor,
    required this.onPressed,
  });

  final String label;
  final String value;
  final bool isSelected;
  final Color activeColor;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onPressed,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(100),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : const Color(0xFF737373),
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SummaryCard extends StatelessWidget {
  const _SummaryCard({
    required this.title,
    required this.amount,
    required this.icon,
    required this.color,
  });

  final String title;
  final int amount;
  final IconData icon;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ShadCard(
      padding: const EdgeInsets.all(20),
      radius: const BorderRadius.all(Radius.circular(28)),
      backgroundColor: Colors.white,
      border: ShadBorder.all(color: color.withValues(alpha: 0.15), width: 1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 14, color: color),
              ),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 12,
                  color: Color(0xFF737373),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '¥${NumberFormat('#,###').format(amount)}',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: color,
              letterSpacing: -0.5,
            ),
          ),
        ],
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
    final accentColor = direction == 'LENT' ? const Color(0xFF007AFF) : const Color(0xFFEF4444);

    return async.when(
      loading: () => Center(
        child: Padding(
          padding: const EdgeInsets.all(48),
          child: CircularProgressIndicator(color: accentColor),
        ),
      ),
      error: (e, _) => Center(child: Text('エラー: $e')),
      data: (list) {
        if (list.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(64.0),
            child: Column(
              children: [
                Icon(LucideIcons.fileX, size: 48, color: Colors.grey.shade200),
                const SizedBox(height: 16),
                Text(
                  '未精算はありません',
                  style: TextStyle(color: Colors.grey.shade400, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          itemBuilder: (context, i) {
            final t = list[i];
            return _TransactionTile(transaction: t, accentColor: accentColor);
          },
        );
      },
    );
  }
}

class _TransactionTile extends ConsumerWidget {
  const _TransactionTile({required this.transaction, required this.accentColor});

  final TransactionItem transaction;
  final Color accentColor;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '¥${NumberFormat('#,###').format(transaction.amount)}',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: accentColor,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 4),
              ShadButton.ghost(
                size: ShadButtonSize.sm,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                onPressed: () {
                  _showActionSheet(context, ref, transaction, accentColor);
                },
                child: const Icon(LucideIcons.ellipsis, size: 20, color: Color(0xFF737373)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showActionSheet(BuildContext context, WidgetRef ref, TransactionItem transaction, Color accentColor) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) {
        final isLent = transaction.direction == 'LENT';
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 24),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                _ActionTile(
                  icon: LucideIcons.pencil,
                  label: '内容を編集する',
                  onTap: () {
                    context.pop();
                    context.push('/transaction/${transaction.id}/edit');
                  },
                ),
                const SizedBox(height: 8),
                _ActionTile(
                  icon: LucideIcons.circleCheck,
                  label: '精算済みにする',
                  accentColor: accentColor,
                  onTap: () async {
                    context.pop();
                    final dio = await ref.read(apiClientProvider.future);
                    final api = ApiService(dio);
                    await api.markTransactionPaid(transaction.id);
                    ref.invalidate(summaryProvider);
                    ref.invalidate(lentListProvider);
                    ref.invalidate(borrowedListProvider);
                  },
                ),
                if (isLent) ...[
                  const SizedBox(height: 8),
                  _ActionTile(
                    icon: LucideIcons.bell,
                    label: 'LINEで催促する',
                    accentColor: accentColor,
                    onTap: () {
                      context.pop();
                      context.push('/transaction/${transaction.id}/reminder');
                    },
                  ),
                ],
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
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

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.icon, required this.label, required this.onTap, this.accentColor});
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: (accentColor ?? const Color(0xFF1F1F1F)).withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: accentColor ?? const Color(0xFF1F1F1F), size: 20),
      ),
      title: Text(label, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15)),
      trailing: const Icon(LucideIcons.chevronRight, size: 16, color: Colors.grey),
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      tileColor: const Color(0xFFF9F9F9),
    );
  }
}
