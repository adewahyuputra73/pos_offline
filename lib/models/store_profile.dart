/// Store profile data used for receipt headers and business info.
class StoreProfile {
  final String storeName;
  final String address;
  final String phone;
  final String? tagline;
  final double taxRate;

  const StoreProfile({
    this.storeName = '',
    this.address = '',
    this.phone = '',
    this.tagline,
    this.taxRate = 0.0,
  });

  StoreProfile copyWith({
    String? storeName,
    String? address,
    String? phone,
    String? tagline,
    double? taxRate,
  }) {
    return StoreProfile(
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      tagline: tagline ?? this.tagline,
      taxRate: taxRate ?? this.taxRate,
    );
  }

  Map<String, dynamic> toJson() => {
        'storeName': storeName,
        'address': address,
        'phone': phone,
        'tagline': tagline,
        'taxRate': taxRate,
      };

  factory StoreProfile.fromJson(Map<String, dynamic> json) => StoreProfile(
        storeName: json['storeName'] as String? ?? '',
        address: json['address'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        tagline: json['tagline'] as String?,
        taxRate: (json['taxRate'] as num?)?.toDouble() ?? 0.0,
      );
}
