import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('設定', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF1F1F1F),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        children: [
          const Text(
            'デフォルト催促文',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF737373), fontSize: 13),
          ),
          const SizedBox(height: 12),
          ShadInput(
            controller: _reminderMsgController,
            maxLines: 4,
            placeholder: const Text('貸している時の催促で使う定型文'),
            padding: const EdgeInsets.all(16),
          ),
          const SizedBox(height: 32),
          ShadButton(
            onPressed: _loading ? null : _save,
            backgroundColor: const Color(0xFF007AFF),
            size: ShadButtonSize.lg,
            decoration: ShadDecoration(
              border: ShadBorder(
                radius: BorderRadius.circular(30),
              ),
            ),
            child: _loading
                ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                : const Text('設定を保存する', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white)),
          ),
          if (_saved)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(LucideIcons.circleCheck, color: Colors.green, size: 16),
                  const SizedBox(width: 8),
                  const Text('保存しました', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                ],
              ),
            ),
          
          const SizedBox(height: 48),
          const Divider(),
          const SizedBox(height: 24),
          const Text(
            'アプリについて',
            style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF737373), fontSize: 13),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: Icon(LucideIcons.info),
            title: const Text('バージョン'),
            trailing: const Text('1.0.0'),
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
      if (mounted) {
        setState(() {
          _loading = false;
          _saved = true;
        });
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted) setState(() => _saved = false);
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('エラー: $e')));
    }
  }
}
