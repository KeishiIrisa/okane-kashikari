import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:intl/intl.dart';

import '../../data/api_service.dart';
import '../../data/models.dart';
import '../authless_device/device_id_provider.dart';
import '../dashboard/dashboard_screen.dart';
import '../../core/widgets/error_view.dart';

final contactsListProvider = FutureProvider<List<ContactItem>>((ref) async {
  final dio = await ref.watch(apiClientProvider.future);
  return ApiService(dio).getContacts();
});

class TransactionFormScreen extends ConsumerStatefulWidget {
  const TransactionFormScreen({
    super.key,
    this.transactionId,
    this.initialDirection,
  });

  final String? transactionId;
  final String? initialDirection;

  @override
  ConsumerState<TransactionFormScreen> createState() =>
      _TransactionFormScreenState();
}

class _TransactionFormScreenState extends ConsumerState<TransactionFormScreen> {
  late bool _isLent;
  String? _contactId;
  final _amountController = TextEditingController();
  final _purposeController = TextEditingController();
  DateTime? _dueDate;
  bool _loading = false;
  bool _amountLimitExceeded = false;

  @override
  void initState() {
    super.initState();
    // initialDirection が 'BORROWED' なら借りた（false）からスタート
    _isLent = widget.initialDirection != 'BORROWED';
    if (widget.transactionId != null) _loadTransaction();
  }

  @override
  void dispose() {
    _amountController.dispose();
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
        final formatted = NumberFormat('#,###').format(t.amount);
        _amountController.text = formatted;
        _amountLimitExceeded = '${t.amount}'.length >= 9;
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
    final accentColor = _isLent
        ? const Color(0xFF007AFF)
        : const Color(0xFFEF4444);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.transactionId == null ? '新しく登録する' : '編集する',
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF1F1F1F),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
        leading: IconButton(
          icon: Icon(LucideIcons.x),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 貸した（青） / 借りた（赤） セレクター
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFFF5F5F5),
                borderRadius: BorderRadius.circular(100),
              ),
              padding: const EdgeInsets.all(4),
              child: Row(
                children: [
                  _TypeButton(
                    label: '貸した',
                    isSelected: _isLent,
                    onPressed: () => setState(() => _isLent = true),
                    activeColor: const Color(0xFF007AFF),
                  ),
                  _TypeButton(
                    label: '借りた',
                    isSelected: !_isLent,
                    onPressed: () => setState(() => _isLent = false),
                    activeColor: const Color(0xFFEF4444),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),

            // 金額入力
            const Text(
              '金額',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF737373),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  '¥',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: accentColor,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ShadInput(
                        controller: _amountController,
                        cursorColor: accentColor,
                        placeholder: Text(
                          '0',
                          style: TextStyle(
                            fontSize: 36,
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade300,
                            letterSpacing: -0.5,
                          ),
                        ),
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          _CommaTextInputFormatter(),
                        ],
                        onChanged: (v) {
                          setState(() {
                            _amountLimitExceeded = v.replaceAll(',', '').length >= 9;
                          });
                        },
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.w600,
                          color: accentColor,
                          letterSpacing: -0.5,
                        ),
                        padding: const EdgeInsets.only(left: 6),
                        decoration: const ShadDecoration(
                          border: ShadBorder.none,
                          focusedBorder: ShadBorder.none,
                        ),
                      ),
                      if (_amountLimitExceeded)
                        const Padding(
                          padding: EdgeInsets.only(left: 6),
                          child: Text(
                            '金額は最大9桁まで入力可能です',
                            style: TextStyle(
                              color: Color(0xFFEF4444),
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
            Divider(height: 40, color: accentColor.withValues(alpha: 0.1)),

            // 相手
            const Text(
              '相手',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF737373),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            contactsAsync.when(
              loading: () => const ShadInput(
                placeholder: Text('読み込み中...'),
                readOnly: true,
                decoration: ShadDecoration(border: ShadBorder.none),
              ),
              error: (e, _) => ErrorView(
                message: '連絡先の取得に失敗しました',
                isLoading: contactsAsync.isLoading,
                onRetry: () => ref.invalidate(contactsListProvider),
              ),
              data: (contacts) {
                return Column(
                  children: [
                    ShadSelect<String>(
                      placeholder: const Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [Text('相手を選択してください')],
                      ),
                      onChanged: (v) => setState(() => _contactId = v),
                      initialValue: _contactId,
                      options: [
                        ...contacts.map(
                          (c) => ShadOption(value: c.id, child: Text(c.name)),
                        ),
                      ],
                      selectedOptionBuilder: (context, value) {
                        final contact = contacts
                            .where((c) => c.id == value)
                            .firstOrNull;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              contact?.name ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        );
                      },
                      decoration: const ShadDecoration(
                        border: ShadBorder.none,
                        focusedBorder: ShadBorder.none,
                      ),
                    ),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ShadButton.ghost(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onPressed: () => _showNewContactDialog(ref),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              LucideIcons.circlePlus,
                              size: 16,
                              color: accentColor,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              '新しい相手を追加する',
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),

            // 内容
            const Text(
              '内容',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF737373),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            ShadInput(
              controller: _purposeController,
              cursorColor: accentColor,
              placeholder: const Text('飲み代、プレゼント代など'),
              leading: Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Icon(LucideIcons.pencil, size: 16, color: accentColor),
              ),
              decoration: const ShadDecoration(
                border: ShadBorder.none,
                focusedBorder: ShadBorder.none,
              ),
            ),
            const SizedBox(height: 32),

            // 期日
            const Text(
              '返済期日',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Color(0xFF737373),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () async {
                final d = await showDatePicker(
                  context: context,
                  initialDate: _dueDate ?? DateTime.now(),
                  firstDate: DateTime.now().subtract(const Duration(days: 365)),
                  lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                  locale: const Locale('ja', 'JP'),
                  builder: (context, child) {
                    return Theme(
                      data: Theme.of(context).copyWith(
                        colorScheme: ColorScheme.light(primary: accentColor),
                      ),
                      child: child!,
                    );
                  },
                );
                if (d != null) setState(() => _dueDate = d);
              },
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFF9F9F9),
                  border: Border.all(color: const Color(0xFFE5E5E5)),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  children: [
                    Icon(LucideIcons.calendar, size: 18, color: accentColor),
                    const SizedBox(width: 12),
                    Text(
                      _dueDate != null
                          ? DateFormat('yyyy年M月d日').format(_dueDate!)
                          : '期限を決めない',
                      style: TextStyle(
                        color: _dueDate != null
                            ? const Color(0xFF1F1F1F)
                            : const Color(0xFF737373),
                        fontWeight: _dueDate != null
                            ? FontWeight.w600
                            : FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    if (_dueDate != null)
                      GestureDetector(
                        onTap: () => setState(() => _dueDate = null),
                        child: Icon(
                          LucideIcons.x,
                          size: 16,
                          color: Colors.grey.shade400,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),

            // 保存ボタン
            ShadButton(
              size: ShadButtonSize.lg,
              onPressed: _loading ? null : _submit,
              backgroundColor: accentColor,
              child: _loading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text(
                      'この内容で登録する',
                      style: TextStyle(
                        fontWeight: FontWeight.w900,
                        fontSize: 16,
                        color: Colors.white,
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showNewContactDialog(WidgetRef ref) async {
    final nameController = TextEditingController();
    final accentColor = _isLent
        ? const Color(0xFF007AFF)
        : const Color(0xFFEF4444);

    await showShadDialog(
      context: context,
      builder: (context) => ShadDialog(
        constraints: const BoxConstraints(maxWidth: 340),
        radius: const BorderRadius.all(Radius.circular(24)),
        title: const Text(
          '新しい相手を登録',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        description: const Text('やり取りする相手の名前を入力してください。'),
        actions: [
          ShadButton.ghost(
            onPressed: () => Navigator.pop(context),
            child: const Text('キャンセル'),
          ),
          ShadButton(
            backgroundColor: accentColor,
            onPressed: () async {
              final name = nameController.text.trim();
              if (name.isEmpty) return;
              try {
                final dio = await ref.read(apiClientProvider.future);
                final api = ApiService(dio);
                final created = await api.createContact(name);
                ref.invalidate(contactsListProvider);
                setState(() => _contactId = created.id);
                if (context.mounted) Navigator.pop(context);
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(
                    context,
                  ).showSnackBar(SnackBar(content: Text('追加に失敗: $e')));
                }
              }
            },
            child: const Text(
              '登録する',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20),
          child: ShadInput(
            controller: nameController,
            placeholder: const Text('例: 田中 太郎'),
            autofocus: true,
            cursorColor: accentColor,
            decoration: ShadDecoration(
              focusedBorder: ShadBorder.all(color: accentColor),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submit() async {
    if (_contactId == null || _contactId!.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('相手を選んでください')));
      return;
    }
    final amountText = _amountController.text.replaceAll(',', '');
    final amount = int.tryParse(amountText);
    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('金額を入力してください')));
      return;
    }
    setState(() => _loading = true);
    try {
      final dio = await ref.read(apiClientProvider.future);
      final api = ApiService(dio);
      final direction = _isLent ? 'LENT' : 'BORROWED';
      String? dueDateStr;
      if (_dueDate != null) {
        dueDateStr =
            '${_dueDate!.toIso8601String().split('T')[0]}T00:00:00.000Z';
      }
      if (widget.transactionId != null) {
        await api.updateTransaction(
          widget.transactionId!,
          contactId: _contactId,
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

      ref.invalidate(summaryProvider);
      ref.invalidate(lentListProvider);
      ref.invalidate(borrowedListProvider);

      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            backgroundColor: Color(0xFF1F1F1F),
            content: Text('保存しました'),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('エラー: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }
}

class _CommaTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    // カンマを除去して数字のみにする
    final String numericText = newValue.text.replaceAll(',', '');

    // 数字以外が含まれている場合は入力を拒否
    if (numericText.isNotEmpty && int.tryParse(numericText) == null) {
      return oldValue;
    }

    // 9桁制限（数値として）
    if (numericText.length > 9) {
      return oldValue;
    }

    final int? value = int.tryParse(numericText);
    if (value == null) {
      return newValue.copyWith(
        text: '',
        selection: const TextSelection.collapsed(offset: 0),
      );
    }

    final String formatted = NumberFormat('#,###').format(value);

    // カーソル位置の調整
    // 入力後の文字列におけるカーソル位置を、数字の数に基づいて計算する
    int cursorOffset = newValue.selection.end;
    int commasBeforeCursor = 0;
    for (int i = 0; i < cursorOffset && i < newValue.text.length; i++) {
      if (newValue.text[i] == ',') {
        commasBeforeCursor++;
      }
    }

    int digitsBeforeCursor = cursorOffset - commasBeforeCursor;
    int newCursorOffset = 0;
    int digitsCount = 0;
    while (digitsCount < digitsBeforeCursor && newCursorOffset < formatted.length) {
      if (formatted[newCursorOffset] != ',') {
        digitsCount++;
      }
      newCursorOffset++;
    }

    // 最後にカンマが追加された場合の調整
    if (newCursorOffset < formatted.length && formatted[newCursorOffset] == ',') {
      newCursorOffset++;
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: newCursorOffset),
    );
  }
}

class _TypeButton extends StatelessWidget {
  const _TypeButton({
    required this.label,
    required this.isSelected,
    required this.onPressed,
    required this.activeColor,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onPressed;
  final Color activeColor;

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
                fontWeight: isSelected ? FontWeight.w900 : FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
