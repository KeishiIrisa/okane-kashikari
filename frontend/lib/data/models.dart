// API レスポンス用モデル（簡易）

class ContactItem {
  final String id;
  final String name;
  final String lastUsedAt;

  ContactItem({required this.id, required this.name, required this.lastUsedAt});

  factory ContactItem.fromJson(Map<String, dynamic> json) {
    return ContactItem(
      id: json['id'] as String,
      name: json['name'] as String,
      lastUsedAt: json['last_used_at'] as String? ?? '',
    );
  }
}

class TransactionItem {
  final String id;
  final String contactId;
  final String contactName;
  final int amount;
  final String purpose;
  final String direction; // LENT | BORROWED
  final String? dueDate;
  final String status; // unpaid | paid
  final String createdAt;
  final String updatedAt;

  TransactionItem({
    required this.id,
    required this.contactId,
    required this.contactName,
    required this.amount,
    required this.purpose,
    required this.direction,
    this.dueDate,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  factory TransactionItem.fromJson(Map<String, dynamic> json) {
    return TransactionItem(
      id: json['id'] as String,
      contactId: json['contact_id'] as String,
      contactName: json['contact_name'] as String? ?? '',
      amount: (json['amount'] as num).toInt(),
      purpose: json['purpose'] as String? ?? '',
      direction: json['direction'] as String,
      dueDate: json['due_date'] as String?,
      status: json['status'] as String? ?? 'unpaid',
      createdAt: json['created_at'] as String? ?? '',
      updatedAt: json['updated_at'] as String? ?? '',
    );
  }
}

class SummaryData {
  final int totalLentUnpaid;
  final int totalBorrowedUnpaid;
  final List<TransactionItem> recentTransactions;

  SummaryData({
    required this.totalLentUnpaid,
    required this.totalBorrowedUnpaid,
    required this.recentTransactions,
  });

  factory SummaryData.fromJson(Map<String, dynamic> json) {
    final recent = json['recent_transactions'] as List<dynamic>? ?? [];
    return SummaryData(
      totalLentUnpaid: (json['total_lent_unpaid'] as num?)?.toInt() ?? 0,
      totalBorrowedUnpaid: (json['total_borrowed_unpaid'] as num?)?.toInt() ?? 0,
      recentTransactions: recent.map((e) => TransactionItem.fromJson(e as Map<String, dynamic>)).toList(),
    );
  }
}
