/// Store profile data used for receipt headers and business info.
class StoreProfile {
  final String storeName;
  final String address;
  final String phone;
  final String? tagline;

  const StoreProfile({
    this.storeName = '',
    this.address = '',
    this.phone = '',
    this.tagline,
  });

  StoreProfile copyWith({
    String? storeName,
    String? address,
    String? phone,
    String? tagline,
  }) {
    return StoreProfile(
      storeName: storeName ?? this.storeName,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      tagline: tagline ?? this.tagline,
    );
  }

  Map<String, dynamic> toJson() => {
        'storeName': storeName,
        'address': address,
        'phone': phone,
        'tagline': tagline,
      };

  factory StoreProfile.fromJson(Map<String, dynamic> json) => StoreProfile(
        storeName: json['storeName'] as String? ?? '',
        address: json['address'] as String? ?? '',
        phone: json['phone'] as String? ?? '',
        tagline: json['tagline'] as String?,
      );
}
