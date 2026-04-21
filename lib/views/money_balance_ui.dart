import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:flutter_money_tracking_app/services/supabase_service.dart';
import 'package:flutter_money_tracking_app/models/user_model.dart';

class MoneyBalanceUI extends StatefulWidget {
  const MoneyBalanceUI({super.key});

  @override
  State<MoneyBalanceUI> createState() => _MoneyBalanceUIState();
}

class _MoneyBalanceUIState extends State<MoneyBalanceUI> {
  final SupabaseService _supabaseService = SupabaseService();

  @override
  Widget build(BuildContext context) {
    final double statusBarHeight = MediaQuery.of(context).padding.top;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          // 1. ส่วนหัวและบัตรยอดเงิน (สไตล์ตามรูปภาพ)
          _buildHeader(statusBarHeight),

          const SizedBox(height: 20),

          Text(
            'เงินเข้า/เงินออก',
            style: GoogleFonts.kanit(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: const Color(0xFF2D2D2D),
            ),
          ),

          const SizedBox(height: 10),

          // 2. ส่วนรายการธุรกรรม
          Expanded(
            child: _buildTransactionList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(double statusBarHeight) {
    return SizedBox(
      height: 280 + statusBarHeight,
      child: Stack(
        children: [
          // พื้นหลังสีเขียวโค้งด้านล่าง
          Container(
            width: double.infinity,
            height: 180 + statusBarHeight,
            padding:
                EdgeInsets.only(top: statusBarHeight + 10, left: 20, right: 20),
            decoration: const BoxDecoration(
              color: Color.fromARGB(255, 108, 92, 250),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Thitipong Juntorn',
                  style: GoogleFonts.kanit(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const CircleAvatar(
                  radius: 20,
                  backgroundImage: AssetImage('/images/man.png'),
                ),
              ],
            ),
          ),

          // บัตรยอดเงินคงเหลือ (ลอยทับ)
          Positioned(
            top: 100 + statusBarHeight,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: const Color.fromARGB(255, 121, 49, 255).withAlpha(230),
                borderRadius: BorderRadius.circular(30),
              ),
              child: _buildBalanceCardContent(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBalanceCardContent() {
    return FutureBuilder<Map<String, double>>(
      future: _supabaseService.getTransactionSummary(),
      builder: (context, snapshot) {
        final summary =
            snapshot.data ?? {'totalIn': 0, 'totalOut': 0, 'balance': 0};

        return Column(
          children: [
            Text(
              'ยอดเงินคงเหลือ',
              style: GoogleFonts.kanit(color: Colors.white, fontSize: 14),
            ),
            const SizedBox(height: 8),
            Text(
              NumberFormat('#,###.00').format(summary['balance']),
              style: GoogleFonts.kanit(
                color: Colors.white,
                fontSize: 38,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 25),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildSummaryItem(Icons.arrow_downward, 'ยอดเงินเข้ารวม',
                    summary['totalIn']!),
                _buildSummaryItem(
                    Icons.arrow_upward, 'ยอดเงินออกรวม', summary['totalOut']!),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryItem(IconData icon, String label, double amount) {
    return Row(
      children: [
        CircleAvatar(
          radius: 12,
          backgroundColor: Colors.white24,
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 8),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label,
                style: GoogleFonts.kanit(color: Colors.white, fontSize: 10)),
            Text(
              NumberFormat('#,###').format(amount),
              style: GoogleFonts.kanit(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14),
            ),
          ],
        )
      ],
    );
  }

  Widget _buildTransactionList() {
    return FutureBuilder<List<UserModel>>(
      future: _supabaseService.getAllPayments(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return Center(child: Text('ไม่มีรายการ', style: GoogleFonts.kanit()));
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          itemCount: snapshot.data!.length,
          separatorBuilder: (context, index) =>
              Divider(color: Colors.grey.withAlpha(30)),
          itemBuilder: (context, index) {
            final data = snapshot.data![index];
            bool isIncome = data.type == 'IN';
            return _buildTransactionItem(data, isIncome);
          },
        );
      },
    );
  }

  Widget _buildTransactionItem(UserModel data, bool isIncome) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor:
                isIncome ? const Color(0xFFE8F5E9) : const Color(0xFFFFEBEE),
            child: Icon(
              isIncome ? Icons.arrow_downward : Icons.arrow_upward,
              color: isIncome ? Colors.green : Colors.redAccent,
              size: 20,
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  data.name ?? 'ไม่ระบุรายการ',
                  style: GoogleFonts.kanit(
                      fontSize: 16, fontWeight: FontWeight.w500),
                ),
                Text(
                  data.createdAt != null
                      ? DateFormat('d เมษายน 2026').format(data.createdAt!)
                      : '',
                  style: GoogleFonts.kanit(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          Text(
            NumberFormat('#,###.00').format(data.amount ?? 0),
            style: GoogleFonts.kanit(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isIncome ? Colors.green : Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}
