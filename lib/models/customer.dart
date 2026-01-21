class Customer {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String address;
  final String taxId;

  Customer({
    required this.id,
    required this.name,
    this.email = '',
    this.phone = '',
    this.address = '',
    this.taxId = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'address': address,
      'taxId': taxId,
    };
  }

  factory Customer.fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      taxId: map['taxId'] ?? '',
    );
  }

  Customer copyWith({
    String? name,
    String? email,
    String? phone,
    String? address,
    String? taxId,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      taxId: taxId ?? this.taxId,
    );
  }
}
