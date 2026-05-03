class Client {
  final int? id;
  final String name;
  final String phone;
  final String? email;
  final String? address;
  final double balance;
  final bool isOwesMe;
  final String? imagePath;

  Client({
    this.id,
    required this.name,
    required this.phone,
    this.email,
    this.address,
    this.balance = 0.0,
    this.isOwesMe = true,
    this.imagePath,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'balance': balance,
      'isOwesMe': isOwesMe ? 1 : 0,
      'imagePath': imagePath,
    };
  }

  factory Client.fromMap(Map<String, dynamic> map) {
    return Client(
      id: map['id'],
      name: map['name'],
      phone: map['phone'],
      email: map['email'],
      address: map['address'],
      balance: map['balance'] ?? 0.0,
      isOwesMe: map['isOwesMe'] == 1,
      imagePath: map['imagePath'],
    );
  }
}
