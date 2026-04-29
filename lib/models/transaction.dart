enum PaymentMethod { cash, qris }

PaymentMethod paymentMethodFromString(String v) {
  switch (v) {
    case 'qris':
      return PaymentMethod.qris;
    case 'cash':
    default:
      return PaymentMethod.cash;
  }
}

String paymentMethodToString(PaymentMethod m) =>
    m == PaymentMethod.qris ? 'qris' : 'cash';

class TransactionItem {
  final String productId;
  final String productName;
  final int price;
  final int quantity;

  const TransactionItem({
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
  });

  int get subtotal => price * quantity;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'productName': productName,
        'price': price,
        'quantity': quantity,
      };

  factory TransactionItem.fromJson(Map<String, dynamic> json) =>
      TransactionItem(
        productId: json['productId'] as String,
        productName: json['productName'] as String? ?? '',
        price: (json['price'] as num).toInt(),
        quantity: (json['quantity'] as num).toInt(),
      );
}

class TransactionRecord {
  final String id;
  final List<TransactionItem> items;
  final int total;
  final int cogs; // Cost of Goods Sold (Modal)
  final PaymentMethod paymentMethod;
  final int? paidAmount; // for cash
  final int? change; // for cash
  final String? qrisImageBase64; // base64-encoded image (no data URI prefix)
  final DateTime createdAt;

  const TransactionRecord({
    required this.id,
    required this.items,
    required this.total,
    required this.cogs,
    required this.paymentMethod,
    required this.createdAt,
    this.paidAmount,
    this.change,
    this.qrisImageBase64,
  });

  int get profit => total - cogs;

  Map<String, dynamic> toJson() => {
        'id': id,
        'items': items.map((e) => e.toJson()).toList(),
        'total': total,
        'cogs': cogs,
        'paymentMethod': paymentMethodToString(paymentMethod),
        'paidAmount': paidAmount,
        'change': change,
        'qrisImage': qrisImageBase64,
        'createdAt': createdAt.toIso8601String(),
      };

  factory TransactionRecord.fromJson(Map<String, dynamic> json) =>
      TransactionRecord(
        id: json['id'] as String,
        items: (json['items'] as List<dynamic>)
            .map((e) => TransactionItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: (json['total'] as num).toInt(),
        cogs: (json['cogs'] as num?)?.toInt() ?? 0, // Default to 0 for older records
        paymentMethod:
            paymentMethodFromString(json['paymentMethod'] as String),
        paidAmount: (json['paidAmount'] as num?)?.toInt(),
        change: (json['change'] as num?)?.toInt(),
        qrisImageBase64: json['qrisImage'] as String?,
        createdAt: DateTime.parse(json['createdAt'] as String),
      );
}
