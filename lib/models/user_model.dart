class AddressModel {
  final String id;
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final String number;
  final bool isDefault;
  final String? label;
  final double? lat;
  final double? long;

  AddressModel({
    required this.id,
    required this.street,
    required this.city,
    required this.state,
    required this.country,
    required this.postalCode,
    required this.number,
    required this.lat,
    required this.long,
    this.isDefault = false,
    this.label,
  });

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      id: map['id']?.toString() ?? '',
      street: map['street']?.toString() ?? '',
      city: map['city']?.toString() ?? '',
      state: map['state']?.toString() ?? '',
      country: map['country']?.toString() ?? '',
      postalCode: map['postalCode']?.toString() ?? '',
      number: map['number']?.toString() ?? '',
      isDefault: map['isDefault'] ?? false,
      label: map['label']?.toString(),
      lat: map['lat']??0,
      long: map['long']??0,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'street': street,
      'city': city,
      'state': state,
      'country': country,
      'postalCode': postalCode,
      'number': number,
      'isDefault': isDefault,
      'label': label,
      'lat': lat,
      'long': long,
    };
  }
}

class UserModel {
  final String id;
  final String? email;
  final String? fullName;
  final String phoneNumber;
  final String? profileImage;
  final List<AddressModel> addresses;
  final DateTime createdAt;
  final bool isActive;
  final String? admin;
  final String? fcmTokens;

  UserModel({
    required this.id,
    this.email,
    this.fullName,
    required this.phoneNumber,
    this.profileImage,
    this.addresses = const [],
    required this.createdAt,
    this.isActive = true,
    this.admin,
    this.fcmTokens,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id']?.toString() ?? '',
      email: map['email']?.toString() ?? '',
      fullName: map['fullName']?.toString() ?? '',
      phoneNumber: map['phoneNumber']?.toString() ?? '',
      profileImage: map['profileImage']?.toString(),
      addresses: List<AddressModel>.from(
        (map['addresses'] ?? []).map((x) => AddressModel.fromMap(x)),
      ),
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'].toString())
          : DateTime.now(),
      isActive: map['isActive'] ?? true,
      admin: map['admin']?.toString(),
      fcmTokens: map['fcmTokens']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'fullName': fullName,
      'phoneNumber': phoneNumber,
      'profileImage': profileImage,
      'addresses': addresses.map((x) => x.toMap()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'isActive': isActive,
      'admin': admin,
      'fcmTokens': fcmTokens,
    };
  }

  UserModel copyWith({
    String? id,
    String? email,
    String? fullName,
    String? phoneNumber,
    String? profileImage,
    List<AddressModel>? addresses,
    DateTime? createdAt,
    bool? isActive,
    String? admin,
    String? fcmTokens,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      fullName: fullName ?? this.fullName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profileImage: profileImage ?? this.profileImage,
      addresses: addresses ?? this.addresses,
      createdAt: createdAt ?? this.createdAt,
      isActive: isActive ?? this.isActive,
      admin: admin ?? this.admin,
      fcmTokens: fcmTokens ?? this.fcmTokens,
    );
  }
}