import 'package:dio/dio.dart';

import 'models.dart';

class ApiService {
  ApiService(this._dio);

  final Dio _dio;

  Future<String> getDefaultReminderMsg() async {
    final r = await _dio.get<Map<String, dynamic>>('/me');
    return (r.data?['default_reminder_msg'] as String?) ?? '';
  }

  Future<void> updateDefaultReminderMsg(String msg) async {
    await _dio.put('/me', data: {'default_reminder_msg': msg});
  }

  Future<SummaryData> getSummary() async {
    final r = await _dio.get<Map<String, dynamic>>('/summary');
    return SummaryData.fromJson(r.data ?? {});
  }

  Future<List<ContactItem>> getContacts() async {
    final r = await _dio.get<List<dynamic>>('/contacts');
    return (r.data ?? []).map((e) => ContactItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<ContactItem> createContact(String name) async {
    final r = await _dio.post<Map<String, dynamic>>('/contacts', data: {'name': name});
    final id = r.data?['id'] as String? ?? '';
    return ContactItem(id: id, name: name, lastUsedAt: '');
  }

  Future<void> updateContact(String id, String name) async {
    await _dio.put('/contacts/$id', data: {'name': name});
  }

  Future<void> deleteContact(String id) async {
    await _dio.delete('/contacts/$id');
  }

  Future<List<TransactionItem>> getTransactions({String? direction, String? status}) async {
    final q = <String, String>{};
    if (direction != null && direction.isNotEmpty) q['direction'] = direction;
    if (status != null && status.isNotEmpty) q['status'] = status;
    final r = await _dio.get<List<dynamic>>('/transactions', queryParameters: q.isEmpty ? null : q);
    return (r.data ?? []).map((e) => TransactionItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<TransactionItem?> getTransaction(String id) async {
    try {
      final r = await _dio.get<Map<String, dynamic>>('/transactions/$id');
      return r.data != null ? TransactionItem.fromJson(r.data!) : null;
    } catch (_) {
      return null;
    }
  }

  Future<String> createTransaction({
    required String contactId,
    required int amount,
    required String purpose,
    required String direction,
    String? dueDate,
  }) async {
    final data = <String, dynamic>{
      'contact_id': contactId,
      'amount': amount,
      'purpose': purpose,
      'direction': direction,
    };
    if (dueDate != null && dueDate.isNotEmpty) data['due_date'] = dueDate;
    final r = await _dio.post<Map<String, dynamic>>('/transactions', data: data);
    return r.data?['id'] as String? ?? '';
  }

  Future<void> updateTransaction(String id, {String? contactId, int? amount, String? purpose, String? dueDate, String? status}) async {
    final data = <String, dynamic>{};
    if (contactId != null) data['contact_id'] = contactId;
    if (amount != null) data['amount'] = amount;
    if (purpose != null) data['purpose'] = purpose;
    if (dueDate != null) data['due_date'] = dueDate;
    if (status != null) data['status'] = status;
    await _dio.put('/transactions/$id', data: data);
  }

  Future<void> deleteTransaction(String id) async {
    await _dio.delete('/transactions/$id');
  }

  Future<void> markTransactionPaid(String id) async {
    await _dio.post('/transactions/$id/mark-paid');
  }

  Future<void> registerDeviceToken(String token, {required String platform}) async {
    await _dio.post('/device/register', data: {
      'token': token,
      'platform': platform,
    });
  }
}
