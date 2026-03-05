import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/api_service.dart';
import '../authless_device/device_id_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final _reminderMsgController = TextEditingController();
  bool _loading = false;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final dio = await ref.read(apiClientProvider.future);
    final msg = await ApiService(dio).getDefaultReminderMsg();
    if (mounted) _reminderMsgController.text = msg;
  }

  @override
  void dispose() {
    _reminderMsgController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('設定')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          const Text('デフォルト催促文', style: TextStyle(fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextField(
            controller: _reminderMsgController,
            maxLines: 3,
            decoration: const InputDecoration(
              border: OutlineInputBorder(),
              hintText: '貸している時の催促で使う定型文',
            ),
          ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: _loading ? null : _save,
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('保存'),
          ),
          if (_saved) const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text('保存しました', style: TextStyle(color: Colors.green)),
          ),
        ],
      ),
    );
  }

  Future<void> _save() async {
    setState(() => _loading = true);
    try {
      final dio = await ref.read(apiClientProvider.future);
      await ApiService(dio).updateDefaultReminderMsg(_reminderMsgController.text);
      if (mounted) setState(() { _loading = false; _saved = true; });
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
    }
  }
}
