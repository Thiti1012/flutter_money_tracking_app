import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_money_tracking_app/models/user_model.dart';

class SupabaseService {
  final _client = Supabase.instance.client;

  // บันทึกข้อมูล
  Future<void> insertPayment(UserModel model) async {
    try {
      await _client.from('money_tb').insert(model.toJson());
    } catch (e) {
      throw Exception('บันทึกข้อมูลไม่สำเร็จ: $e');
    }
  }

  // ดึงข้อมูลทั้งหมดเรียงจากใหม่ไปเก่า
  Future<List<UserModel>> getAllPayments() async {
    try {
      final response = await _client
          .from('money_tb')
          .select()
          .order('created_at', ascending: false);

      return (response as List)
          .map((item) => UserModel.fromJson(item))
          .toList();
    } catch (e) {
      throw Exception('ดึงข้อมูลไม่สำเร็จ: $e');
    }
  }

  // คำนวณยอดสรุปสำหรับหน้า Dashboard
  Future<Map<String, double>> getTransactionSummary() async {
    try {
      final response = await _client.from('money_tb').select('data');
      double totalIn = 0;
      double totalOut = 0;

      for (var item in response) {
        final data = item['data'] as Map<String, dynamic>;
        double amount = (data['amount'] ?? 0).toDouble();

        // ✅ แก้ไขตรงนี้: ใส่ปีกกาให้ if และ else ตามที่ Diagnostic แจ้ง
        if (data['type'] == 'IN') {
          totalIn += amount;
        } else {
          totalOut += amount;
        }
      }

      return {
        'totalIn': totalIn,
        'totalOut': totalOut,
        'balance': totalIn - totalOut
      };
    } catch (e) {
      return {'totalIn': 0, 'totalOut': 0, 'balance': 0};
    }
  }
}
