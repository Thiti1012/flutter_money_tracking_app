import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_money_tracking_app/services/supabase_service.dart';
import 'package:flutter_money_tracking_app/models/user_model.dart';
import 'package:intl/intl.dart';

class MoneyOutUI extends StatefulWidget {
  const MoneyOutUI({super.key});

  @override
  State<MoneyOutUI> createState() => _MoneyOutUIState();
}

class _MoneyOutUIState extends State<MoneyOutUI> {
  final Color outColor = const Color(0xFFE57373); // สีแดง-ชมพูสำหรับรายจ่าย
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // 1. เรียกใช้งาน SupabaseService
  final SupabaseService _supabaseService = SupabaseService();

  // 2. ลบคำว่า final ออกเพื่อให้ยอดเงินอัปเดตได้
  double _currentBalance = 0.00;

  // 3. สร้าง initState สำหรับดึงยอดเงินปัจจุบันตอนเปิดหน้านี้
  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  // ฟังก์ชันดึงยอดเงินจากฐานข้อมูล
  Future<void> _fetchBalance() async {
    final summary = await _supabaseService.getTransactionSummary();
    setState(() {
      _currentBalance = summary['balance'] ?? 0.00;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // เพิ่มบรรทัดนี้เข้าไป: ดึงเวลาปัจจุบันและจัดฟอร์แมตเป็น วัน เดือน(ไทย) ปี
    String currentDate = DateFormat('d MMMM yyyy', 'th').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      // ... โค้ดเดิม ...
      body: Column(
        children: [
          // ส่วน Header: โปรไฟล์และยอดเงินปัจจุบัน
          _buildHeader(context),

          // ส่วน Form: กรอกข้อมูลรายจ่าย
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 40),
              child: Column(
                children: [
                  Text(
                    currentDate,
                    style: GoogleFonts.kanit(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: const Color(0xFF2D2D2D),
                    ),
                  ),
                  Text(
                    'บันทึกรายจ่าย',
                    style: GoogleFonts.kanit(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 35),
                  _inputSection(
                    label: 'รายการรายจ่าย',
                    controller: _noteController,
                    hint: 'เช่น ค่าอาหาร, ค่าเดินทาง',
                  ),
                  const SizedBox(height: 20),
                  _inputSection(
                    label: 'จำนวนเงินรายจ่าย',
                    controller: _amountController,
                    hint: '0.00',
                    isNumber: true,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      // 4. แก้ไขการทำงานของปุ่มยืนยัน
                      onPressed: () async {
                        if (_amountController.text.isNotEmpty &&
                            _noteController.text.isNotEmpty) {
                          try {
                            // แปลงค่าเงิน
                            final parsedAmount =
                                (double.tryParse(_amountController.text) ?? 0)
                                    .toInt();

                            // สร้าง Model กำหนดเป็น type 'OUT'
                            final newRecord = UserModel(
                              name: _noteController.text,
                              amount: parsedAmount,
                              type: 'OUT',
                            );

                            // สั่งบันทึกลง Supabase
                            await _supabaseService.insertPayment(newRecord);

                            if (context.mounted) {
                              // เด้งกลับหน้า Home และรีโหลดหน้าใหม่เพื่อให้ยอดอัปเดต
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/home', (route) => false);

                              // แสดงแจ้งเตือน
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'บันทึกรายจ่ายและอัปเดตยอดเงินเรียบร้อย!'),
                                  backgroundColor: Color(0xFFE57373),
                                ),
                              );
                            }
                          } catch (e) {
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('เกิดข้อผิดพลาด: $e')),
                              );
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text('กรุณากรอกรายการและจำนวนเงินรายจ่าย')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: outColor,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: Text(
                        'ยืนยันบันทึกรายจ่าย',
                        style: GoogleFonts.kanit(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: double.infinity,
            height: 180,
            decoration: BoxDecoration(
              color: outColor,
              borderRadius: const BorderRadius.only(
                bottomLeft: Radius.circular(50),
                bottomRight: Radius.circular(50),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 10,
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        color: Colors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        // เปลี่ยนจาก Navigator.pop(context) เป็นการเจาะจงกลับไปหน้า Home
                        Navigator.pushReplacementNamed(context, '/home');
                      },
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          'Thitipong Juntorn',
                          style: GoogleFonts.kanit(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const CircleAvatar(
                      radius: 22,
                      backgroundColor: Colors.white24,
                      backgroundImage: AssetImage('/images/man.png'),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -20,
            left: 25,
            right: 25,
            child: Container(
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFD32F2F).withOpacity(0.8),
                borderRadius: BorderRadius.circular(30),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'ยอดเงินคงเหลือปัจจุบัน',
                    style: GoogleFonts.kanit(
                      color: Colors.white70,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    _currentBalance.toStringAsFixed(2),
                    style: GoogleFonts.kanit(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _inputSection({
    required String label,
    required TextEditingController controller,
    String? hint,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 10, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.kanit(
              color: outColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: TextField(
            controller: controller,
            keyboardType: isNumber ? TextInputType.number : TextInputType.text,
            decoration: InputDecoration(
              hintText: hint,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              border: InputBorder.none,
              hintStyle: GoogleFonts.kanit(color: Colors.grey.shade400),
            ),
          ),
        ),
      ],
    );
  }
}
