import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_money_tracking_app/services/supabase_service.dart';
import 'package:flutter_money_tracking_app/models/user_model.dart';
import 'package:intl/intl.dart';

class MoneyInUI extends StatefulWidget {
  const MoneyInUI({super.key});

  @override
  State<MoneyInUI> createState() => _MoneyInUIState();
}

class _MoneyInUIState extends State<MoneyInUI> {
  final Color primaryColor = const Color(0xFF458F8B);
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  // 1. เรียกใช้งาน SupabaseService เพื่อเตรียมดึงข้อมูล
  final SupabaseService _supabaseService = SupabaseService();

  // 2. ลบคำว่า final ออกจาก _currentBalance เพื่อให้ตัวเลขมันอัปเดตได้
  double _currentBalance = 0.00;

  // 3. เพิ่มฟังก์ชัน initState เพื่อดึงข้อมูล "ทันที" ที่โหลดหน้านี้ขึ้นมา
  @override
  void initState() {
    super.initState();
    _fetchBalance();
  }

  // 4. ฟังก์ชันคำนวณยอดเงินและอัปเดตหน้าจอ
  Future<void> _fetchBalance() async {
    final summary = await _supabaseService.getTransactionSummary();
    setState(() {
      // ดึงค่า balance มาใส่ตัวแปร ถ้าดึงไม่ได้ให้เป็น 0.00
      _currentBalance = summary['balance'] ?? 0.00;
    });
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  // ... (ส่วน @override Widget build(BuildContext context) ด้านล่างปล่อยไว้เหมือนเดิม ไม่ต้องแก้ครับ) ...
  @override
  Widget build(BuildContext context) {
    // เพิ่มบรรทัดนี้เข้าไป: ดึงเวลาปัจจุบันและจัดฟอร์แมตเป็น วัน เดือน(ไทย) ปี
    String currentDate = DateFormat('d MMMM yyyy', 'th').format(DateTime.now());

    return Scaffold(
      backgroundColor: Colors.white,
      // ... โค้ดเดิม ...
      body: Column(
        children: [
          _buildHeader(context),
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
                    'บันทึกเงินเข้า',
                    style: GoogleFonts.kanit(fontSize: 16, color: Colors.grey),
                  ),
                  const SizedBox(height: 35),
                  _inputSection(
                    label: 'รายการเงินเข้า',
                    controller: _noteController,
                    hint: 'เช่น เงินเดือน, โอนเข้า',
                  ),
                  const SizedBox(height: 20),
                  _inputSection(
                    label: 'จำนวนเงินเข้า',
                    controller: _amountController,
                    hint: '0.00',
                    isNumber: true,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton(
                      onPressed: () async {
                        // 1. ตรวจสอบความถูกต้องของข้อมูล
                        if (_amountController.text.isNotEmpty &&
                            _noteController.text.isNotEmpty) {
                          try {
                            final parsedAmount =
                                (double.tryParse(_amountController.text) ?? 0)
                                    .toInt();

                            // สร้าง Model (ถ้าเป็นหน้าเงินออก อย่าลืมเปลี่ยน type เป็น 'OUT' นะครับ)
                            final newRecord = UserModel(
                              name: _noteController.text,
                              amount: parsedAmount,
                              type: 'IN',
                            );

                            // 2. บันทึกข้อมูลลงฐานข้อมูล Supabase
                            await SupabaseService().insertPayment(newRecord);

                            // 3. ตรวจสอบว่า Context ยังอยู่ไหมก่อนเปลี่ยนหน้า
                            if (context.mounted) {
                              // ⭐ จุดสำคัญ: เด้งกลับหน้า Home และ Reload ข้อมูล
                              // การใช้ pushNamedAndRemoveUntil จะทำให้แอปกลับไปเริ่มที่หน้า Home ใหม่
                              // หน้าสรุปยอดจะดึงข้อมูลล่าสุดมาโชว์ทันที
                              Navigator.pushNamedAndRemoveUntil(
                                  context, '/home', (route) => false);

                              // แสดง SnackBar แจ้งเตือนว่าบันทึกแล้ว
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                      'บันทึกข้อมูลและอัปเดตยอดเงินเรียบร้อย!'),
                                  backgroundColor: Color(0xFF458F8B),
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
                                content: Text(
                                    'กรุณากรอกข้อมูลให้ครบถ้วนก่อนบันทึก')),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        shape: const StadiumBorder(),
                        elevation: 0,
                      ),
                      child: Text(
                        'ยืนยันบันทึกรายรับ',
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
              color: primaryColor,
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
                          'Thitipong Juntorn', // ปรับชื่อให้เป็นชื่อเดียวกัน
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
                      // ใช้รูปเดียวกับหน้า balance_ui
                      backgroundImage: AssetImage(
                        '/images/man.png',
                      ),
                      // หากรูปไม่โหลด จะแสดง Icon แทนเพื่อกัน error
                      child: null,
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
                color: const Color(0xFF3E837E),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12,
                    blurRadius: 10,
                    offset: const Offset(0, 5),
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
              color: primaryColor,
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
