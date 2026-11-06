int _int(Object? v) => (v as num?)?.toInt() ?? 0;

DateTime? _date(Object? v) => DateTime.tryParse(v as String? ?? '')?.toLocal();

/// Egy vállalkozói szabadság / zárva tartás (egy munkatársra vagy az egész vállalkozásra).
class OwnerLeave {
  const OwnerLeave({
    required this.id,
    required this.dateFrom,
    required this.dateTo,
    required this.affectedCount,
    this.staffName,
    this.reason,
  });

  final int id;
  final String? staffName;
  final DateTime dateFrom;
  final DateTime dateTo;
  final String? reason;
  final int affectedCount;

  factory OwnerLeave.fromJson(Map<String, dynamic> j) => OwnerLeave(
    id: _int(j['id']),
    staffName: (j['staff'] as Map<String, dynamic>?)?['name'] as String?,
    dateFrom: DateTime.tryParse(j['date_from'] as String? ?? '') ?? DateTime.now(),
    dateTo: DateTime.tryParse(j['date_to'] as String? ?? '') ?? DateTime.now(),
    reason: j['reason'] as String?,
    affectedCount: _int(j['affected_appointments_count']),
  );
}

/// Egy értesítés a vállalkozónak (`GET /businesses/{id}/notifications`).
class AppNotification {
  const AppNotification({required this.id, required this.message, required this.isRead, this.type, this.url, this.createdAt});

  final int id;
  final String? type;
  final String message;
  final String? url;
  final bool isRead;
  final DateTime? createdAt;

  factory AppNotification.fromJson(Map<String, dynamic> j) => AppNotification(
    id: _int(j['id']),
    type: j['type'] as String?,
    message: j['message'] as String? ?? '',
    url: j['url'] as String?,
    isRead: j['read_at'] != null,
    createdAt: _date(j['created_at']),
  );
}

class NotificationListing {
  const NotificationListing({required this.notifications, required this.unreadCount});

  final List<AppNotification> notifications;
  final int unreadCount;

  factory NotificationListing.fromJson(Map<String, dynamic> j) => NotificationListing(
    notifications: [for (final e in (j['notifications'] as List?) ?? const []) AppNotification.fromJson(e as Map<String, dynamic>)],
    unreadCount: _int(j['unread_count']),
  );
}

/// Letöltött fájl: tartalom és a szerver által javasolt fájlnév.
class DownloadedFile {
  const DownloadedFile({required this.bytes, required this.name});

  final List<int> bytes;
  final String name;

  /// A `Content-Disposition` fejlécből a fájlnév; ha nincs, az alapértelmezett.
  static String nameFrom(String? header, String fallback) {
    final match = RegExp(r'filename\*?=(?:UTF-8\x27\x27)?"?([^";]+)"?').firstMatch(header ?? '');
    final name = match?.group(1)?.trim();
    return name == null || name.isEmpty ? fallback : Uri.decodeComponent(name);
  }
}
