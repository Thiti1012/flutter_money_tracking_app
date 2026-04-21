class UserModel {
  final String? id;
  final String? name; // รายการ
  final int? amount; // จำนวนเงิน (เดิมคือ age)
  final String? type; // ประเภท IN หรือ OUT (เดิมคือ zipcode)
  final DateTime? createdAt;

  UserModel({
    this.id,
    this.name,
    this.amount,
    this.type,
    this.createdAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    // ดึงข้อมูลจากคอลัมน์ data (JSONB) ใน Supabase
    final Map<String, dynamic> extraData = json['data'] ?? {};

    return UserModel(
      id: json['id'],
      name: extraData['name'] ?? 'ไม่มีชื่อรายการ',
      amount: extraData['amount'] ?? 0,
      type: extraData['type'] ?? 'IN',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'data': {
        'name': name,
        'amount': amount,
        'type': type,
      },
    };
  }
}
