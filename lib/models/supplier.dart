class Supplier {
  final String id;
  final String name;
  final String contactName;
  final String phone;
  final String email;
  final String category;

  Supplier({
    required this.id,
    required this.name,
    this.contactName = '',
    this.phone = '',
    this.email = '',
    this.category = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'contactName': contactName,
      'phone': phone,
      'email': email,
      'category': category,
    };
  }

  factory Supplier.fromMap(Map<String, dynamic> map) {
    return Supplier(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      contactName: map['contactName'] ?? '',
      phone: map['phone'] ?? '',
      email: map['email'] ?? '',
      category: map['category'] ?? '',
    );
  }

  Supplier copyWith({
    String? name,
    String? contactName,
    String? phone,
    String? email,
    String? category,
  }) {
    return Supplier(
      id: id,
      name: name ?? this.name,
      contactName: contactName ?? this.contactName,
      phone: phone ?? this.phone,
      email: email ?? this.email,
      category: category ?? this.category,
    );
  }
}
