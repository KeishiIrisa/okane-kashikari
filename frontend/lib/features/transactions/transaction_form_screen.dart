import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../data/api_service.dart';
import '../../data/models.dart';
import '../authless_device/device_id_provider.dart';
import '../dashboard/dashboard_screen.dart';

final contactsListProvider = FutureProvider<List<ContactItem>>((ref) async {
  final dio = await ref.watch(apiClientProvider.future);
  return ApiService(dio).getContacts();
});

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({super.key, this.transactionId});

  final String? transactionId;

  @override
  ConsumerState<TransactionFormScreen> createState() => _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  bool _isLent = true; // 貸した
  String? _contactId;
  String _amountStr = '';
  final _purposeController = TextEditingController();
  DateTime? _dueDate;
  bool _loading = false;

  @override
  void initState() {
    super.initState();
    if (widget.transactionId != null) _loadTransaction();
  }

  @override
  void dispose() {
    _purposeController.dispose();
    super.dispose();
  }

  Future<void> _loadTransaction() async {
    final dio = await ref.read(apiClientProvider.future);
    final api = ApiService(dio);
    final t = await api.getTransaction(widget.transactionId!);
    if (t != null && mounted) {
      setState(() {
        _isLent = t.direction == 'LENT';
        _contactId = t.contactId;
        _amountStr = '${t.amount}';
        _purposeController.text = t.purpose;
        if (t.dueDate != null && t.dueDate!.isNotEmpty) {
          try {
            _dueDate = DateTime.parse(t.dueDate!);
          } catch (_) {}
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(contactsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.transactionId == null ? '新規登録' : '編集'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text('貸した / 借りた', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(value: true, label: Text('貸した'), icon: Icon(Icons.arrow_upward)),
                      ButtonSegment(value: false, label: Text('借りた'), icon: Icon(Icons.arrow_downward)),
                    ],
                    selected: {_isLent},
                    onSelectionChanged: (s) => setState(() => _isLent = s.first),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text('相手', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            contactsAsync.when(
              loading: () => const SizedBox(height: 48, child: Center(child: CircularProgressIndicator())),
              error: (e, _) => Text('読み込みエラー: $e'),
              data: (contacts) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    DropdownButtonFormField<String>(
                      value: _contactId,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      hint: const Text('選択'),
                      items: [
                        ...contacts.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))),
                      ],
                      onChanged: (v) => setState(() => _contactId = v),
                    ),
                    TextButton.icon(
                      onPressed: () => _showNewContactDialog(ref, contacts),
                      icon: const Icon(Icons.add),
                      label: const Text('新しい相手を追加'),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            const Text('金額', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              key: ValueKey(_amountStr),
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                prefixText: '¥ ',
              ),
              initialValue: _amountStr,
              onChanged: (v) => setState(() => _amountStr = v.replaceAll(RegExp(r'[^0-9]'), '')),
            ),
            const SizedBox(height: 24),
            const Text('内容', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextFormField(
              controller: _purposeController,
              decoration: const InputDecoration(border: OutlineInputBorder(), hintText: '飲み代、ドライブ代など'),
            ),
            const SizedBox(height: 24),
            const Text('期日（未設定なら通知なし）', style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            ListTile(
              title: Text(_dueDate != null ? '${_dueDate!.year}/${_dueDate!.month}/${_dueDate!.day}' : '未設定'),
              trailing: const Icon(Icons.calendar_today),
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                );
                if (d != null) setState(() => _dueDate = d);
              },
            ),
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(strokeWidth: 2)) : const Text('保存'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showNewContactDialog(WidgetRef ref, List<ContactItem> contacts) async {
    final nameController = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新しい相手'),
        content: TextField(
          controller: nameController,
          decoration: const InputDecoration(labelText: '名前'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('キャンセル')),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, nameController.text.trim()),
            child: const Text('追加'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty) return;
    try {
      final dio = await ref.read(apiClientProvider.future);
      final api = ApiService(dio);
      final created = await api.createContact(result);
      ref.invalidate(contactsListProvider);
      setState(() => _contactId = created.id);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('追加に失敗: $e')));
    }
  }

  Future<void> _submit() async {
    if (_contactId == null || _contactId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('相手を選んでください')));
      return;
    }
    final amount = int.tryParse(_amountStr.replaceAll(RegExp(r'[^0-9]'), ''));
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('金額を入力してください')));
      return;
    }
    if (_purposeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('内容を入力してください')));
      return;
    }
    setState(() => _loading = true);
    try {
      final dio = await ref.read(apiClientProvider.future);
      final api = ApiService(dio);
      final direction = _isLent ? 'LENT' : 'BORROWED';
      String? dueDateStr;
      if (_dueDate != null) {
        dueDateStr = '${_dueDate!.toIso8601String().split('T')[0]}T00:00:00.000Z';
      }
      if (widget.transactionId != null) {
        await api.updateTransaction(
          widget.transactionId!,
          amount: amount,
          purpose: _purposeController.text.trim(),
          dueDate: dueDateStr,
        );
      } else {
        await api.createTransaction(
          contactId: _contactId!,
          amount: amount,
          purpose: _purposeController.text.trim(),
          direction: direction,
          dueDate: dueDateStr,
        );
      }

      // 一覧・サマリーを最新状態にリフレッシュ
      ref.invalidate(summaryProvider);
      ref.invalidate(lentListProvider);
      ref.invalidate(borrowedListProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('保存しました')));
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}
