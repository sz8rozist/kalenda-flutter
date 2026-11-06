int _int(Object? v) => (v as num?)?.toInt() ?? 0;

DateTime? _date(Object? v) => DateTime.tryParse(v as String? ?? '')?.toLocal();

/// A lapozott (Spring `PagedModel`) válasz tartalma: `{content: [...]}`.
List<Map<String, dynamic>> pagedContent(Object? paged) {
  final content = (paged is Map<String, dynamic> ? paged['content'] : null) as List? ?? const [];
  return [for (final e in content) e as Map<String, dynamic>];
}

/// Egy költség (`GET /businesses/{id}/expenses`).
class Expense {
  const Expense({
    required this.id,
    required this.category,
    required this.amountHuf,
    required this.date,
    required this.isRecurring,
    required this.hasReceipt,
    this.vendor,
  });

  final int id;
  final String category;
  final int amountHuf;
  final DateTime? date;
  final String? vendor;
  final bool isRecurring;
  final bool hasReceipt;

  factory Expense.fromJson(Map<String, dynamic> j) => Expense(
    id: _int(j['id']),
    category: j['category'] as String? ?? '',
    amountHuf: _int(j['amount_huf']),
    date: _date(j['expense_date']),
    vendor: j['vendor'] as String?,
    isRecurring: j['is_recurring'] as bool? ?? false,
    hasReceipt: j['has_receipt'] as bool? ?? false,
  );
}

/// A költségek listája és a már használt kategóriák (javaslatnak).
class ExpenseListing {
  const ExpenseListing({required this.expenses, required this.categories});

  final List<Expense> expenses;
  final List<String> categories;

  int get totalHuf => expenses.fold(0, (sum, e) => sum + e.amountHuf);

  factory ExpenseListing.fromJson(Map<String, dynamic> j) => ExpenseListing(
    expenses: [for (final e in pagedContent(j['expenses'])) Expense.fromJson(e)],
    categories: [for (final c in (j['categories'] as List?) ?? const []) c as String],
  );
}

/// Egy beérkezett értékelés.
class ReviewRow {
  const ReviewRow({
    required this.id,
    required this.rating,
    this.feedback,
    this.customerName,
    this.serviceName,
    this.staffName,
    this.submittedAt,
  });

  final int id;
  final int rating;
  final String? feedback;
  final String? customerName;
  final String? serviceName;
  final String? staffName;
  final DateTime? submittedAt;

  factory ReviewRow.fromJson(Map<String, dynamic> j) => ReviewRow(
    id: _int(j['id']),
    rating: _int(j['rating']),
    feedback: j['feedback'] as String?,
    customerName: j['customer_name'] as String?,
    serviceName: j['service_name'] as String?,
    staffName: j['staff_name'] as String?,
    submittedAt: _date(j['submitted_at']),
  );
}

/// Az értékelések, összesítő és beállítás (`GET /businesses/{id}/reviews`).
class ReviewListing {
  const ReviewListing({
    required this.reviews,
    required this.enabled,
    required this.count,
    required this.average,
    required this.requested,
    this.googleReviewUrl,
  });

  final List<ReviewRow> reviews;
  final bool enabled;
  final String? googleReviewUrl;
  final int count;
  final double average;
  final int requested;

  factory ReviewListing.fromJson(Map<String, dynamic> j) {
    final settings = (j['settings'] as Map<String, dynamic>?) ?? const {};
    final stats = (j['stats'] as Map<String, dynamic>?) ?? const {};
    return ReviewListing(
      reviews: [for (final e in pagedContent(j['reviews'])) ReviewRow.fromJson(e)],
      enabled: settings['reviews_enabled'] as bool? ?? false,
      googleReviewUrl: settings['google_review_url'] as String?,
      count: _int(stats['count']),
      average: (stats['average'] as num?)?.toDouble() ?? 0,
      requested: _int(stats['requested']),
    );
  }
}

/// Egy eladott bérlet vagy ajándékutalvány.
class SoldPass {
  const SoldPass({
    required this.id,
    required this.name,
    required this.kind,
    this.code,
    this.purchaserEmail,
    this.recipientName,
    this.sessionsRemaining,
    this.balanceHuf,
    this.expiresAt,
  });

  final int id;
  final String name;

  /// `pass` (alkalombérlet) | `voucher` (értékutalvány).
  final String kind;
  final String? code;
  final String? purchaserEmail;
  final String? recipientName;
  final int? sessionsRemaining;
  final int? balanceHuf;
  final DateTime? expiresAt;

  factory SoldPass.fromJson(Map<String, dynamic> j) => SoldPass(
    id: _int(j['id']),
    name: j['name'] as String? ?? '',
    kind: j['kind'] as String? ?? 'pass',
    code: j['code'] as String?,
    purchaserEmail: j['purchaser_email'] as String?,
    recipientName: j['recipient_name'] as String?,
    sessionsRemaining: (j['sessions_remaining'] as num?)?.toInt(),
    balanceHuf: (j['balance_huf'] as num?)?.toInt(),
    expiresAt: _date(j['expires_at']),
  );
}

/// Egy várólista-bejegyzés.
class WaitlistEntry {
  const WaitlistEntry({
    required this.id,
    required this.status,
    required this.customerName,
    this.customerEmail,
    this.customerPhone,
    this.preferredDate,
    this.serviceName,
    this.staffName,
  });

  final int id;

  /// `waiting` | `notified` | `booked` | `expired`.
  final String status;
  final String customerName;
  final String? customerEmail;
  final String? customerPhone;
  final DateTime? preferredDate;
  final String? serviceName;
  final String? staffName;

  factory WaitlistEntry.fromJson(Map<String, dynamic> j) => WaitlistEntry(
    id: _int(j['id']),
    status: j['status'] as String? ?? 'waiting',
    customerName: j['customer_name'] as String? ?? '',
    customerEmail: j['customer_email'] as String?,
    customerPhone: j['customer_phone'] as String?,
    preferredDate: _date(j['preferred_date']),
    serviceName: (j['service'] as Map<String, dynamic>?)?['name'] as String?,
    staffName: (j['staff'] as Map<String, dynamic>?)?['name'] as String?,
  );
}

/// Egy bejegyzés a tevékenység-naplóban.
class ActivityEntry {
  const ActivityEntry({
    required this.id,
    required this.action,
    required this.actorName,
    this.subjectType,
    this.subjectLabel,
    this.createdAt,
  });

  final int id;
  final String action;
  final String actorName;
  final String? subjectType;
  final String? subjectLabel;
  final DateTime? createdAt;

  factory ActivityEntry.fromJson(Map<String, dynamic> j) => ActivityEntry(
    id: _int(j['id']),
    action: j['action'] as String? ?? '',
    actorName: j['actor_name'] as String? ?? '',
    subjectType: j['subject_type'] as String?,
    subjectLabel: j['subject_label'] as String?,
    createdAt: _date(j['created_at']),
  );
}
