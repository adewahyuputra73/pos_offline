/// Represents a single cashier shift (sesi kasir).
///
/// A shift starts when a cashier opens it (with opening cash count) and ends
/// when they close it (with closing cash count + optional notes).
/// Transactions belonging to a shift are determined by time range:
/// [openedAt] ≤ transaction.createdAt < [closedAt] (or now for active shift).
class Shift {
  final String id;
  final String cashierName;
  final int openingCash;
  final int? closingCash;
  final DateTime openedAt;
  final DateTime? closedAt;
  final String? notes;

  // Snapshot stats recorded at close time (null = still active)
  final int? snapshotTransactions;
  final int? snapshotRevenue;
  final int? snapshotCash;
  final int? snapshotQris;
  final int? snapshotTax;

  const Shift({
    required this.id,
    required this.cashierName,
    required this.openingCash,
    required this.openedAt,
    this.closingCash,
    this.closedAt,
    this.notes,
    this.snapshotTransactions,
    this.snapshotRevenue,
    this.snapshotCash,
    this.snapshotQris,
    this.snapshotTax,
  });

  bool get isActive => closedAt == null;

  Duration get duration {
    final end = closedAt ?? DateTime.now();
    return end.difference(openedAt);
  }

  String get durationLabel {
    final d = duration;
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}j ${m}m';
    return '${m} menit';
  }

  Shift copyWith({
    String? id,
    String? cashierName,
    int? openingCash,
    int? closingCash,
    DateTime? openedAt,
    DateTime? closedAt,
    String? notes,
    int? snapshotTransactions,
    int? snapshotRevenue,
    int? snapshotCash,
    int? snapshotQris,
    int? snapshotTax,
  }) {
    return Shift(
      id: id ?? this.id,
      cashierName: cashierName ?? this.cashierName,
      openingCash: openingCash ?? this.openingCash,
      closingCash: closingCash ?? this.closingCash,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      notes: notes ?? this.notes,
      snapshotTransactions: snapshotTransactions ?? this.snapshotTransactions,
      snapshotRevenue: snapshotRevenue ?? this.snapshotRevenue,
      snapshotCash: snapshotCash ?? this.snapshotCash,
      snapshotQris: snapshotQris ?? this.snapshotQris,
      snapshotTax: snapshotTax ?? this.snapshotTax,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'cashierName': cashierName,
        'openingCash': openingCash,
        'closingCash': closingCash,
        'openedAt': openedAt.toIso8601String(),
        'closedAt': closedAt?.toIso8601String(),
        'notes': notes,
        'snapshotTransactions': snapshotTransactions,
        'snapshotRevenue': snapshotRevenue,
        'snapshotCash': snapshotCash,
        'snapshotQris': snapshotQris,
        'snapshotTax': snapshotTax,
      };

  factory Shift.fromJson(Map<String, dynamic> json) => Shift(
        id: json['id'] as String,
        cashierName: json['cashierName'] as String? ?? '',
        openingCash: (json['openingCash'] as num?)?.toInt() ?? 0,
        closingCash: (json['closingCash'] as num?)?.toInt(),
        openedAt: DateTime.parse(json['openedAt'] as String),
        closedAt: json['closedAt'] != null
            ? DateTime.parse(json['closedAt'] as String)
            : null,
        notes: json['notes'] as String?,
        snapshotTransactions: (json['snapshotTransactions'] as num?)?.toInt(),
        snapshotRevenue: (json['snapshotRevenue'] as num?)?.toInt(),
        snapshotCash: (json['snapshotCash'] as num?)?.toInt(),
        snapshotQris: (json['snapshotQris'] as num?)?.toInt(),
        snapshotTax: (json['snapshotTax'] as num?)?.toInt(),
      );
}
