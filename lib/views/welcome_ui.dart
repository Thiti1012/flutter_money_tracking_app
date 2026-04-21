import 'package:flutter/material.dart';
import 'package:flutter_money_tracking_app/views/home_ui.dart';

class WelcomeUi extends StatefulWidget {
  const WelcomeUi({super.key});

  @override
  State<WelcomeUi> createState() => _WelcomeUiState();
}

class _WelcomeUiState extends State<WelcomeUi> {
  @override
  Widget build(BuildContext context) {
    // ดึงขนาดหน้าจอมาใช้เพื่อคำนวณสัดส่วน
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.white, // กำหนดสีพื้นหลังหลักส่วนล่าง
      // เปลี่ยนจาก Center(child: Column(...)) เป็น Column ตรงๆ
      body: Column(
        // crossAxisAlignment.stretch เพื่อทำให้ลูกๆ ขยายเต็มความกว้าง
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ส่วนที่ 1: รูปภาพและวงกลมด้านบน
          // ผมยังคงกำหนดความสูงประมาณ 60% ของหน้าจอ เพื่อให้ภาพอยู่ส่วนบน
          // แต่เปลี่ยนการ fit เป็น BoxFit.contain เพื่อไม่ให้ภาพถูกตัดขอบ
          // **คำเตือน**: ตรวจสอบ path ของรูปภาพของคุณให้ถูกต้อง (ปกติจะเป็น assets/images/...)
          Image.asset(
            '/images/welcome.png', // path ที่คุณส่งมา
            height: size.height * 0.7,
            width: size.width * 1.0,
            fit: BoxFit
                .contain, // ปรับเปลี่ยนจาก BoxFit.cover เป็น BoxFit.contain เพื่อให้เห็นภาพทั้งหมดและไม่ถูกตัด
          ),

          // เว้นระยะเล็กน้อย
          const SizedBox(height: 30),

          // ส่วนที่ 2: ข้อความ
          const Text(
            'บันทึก',
            style: TextStyle(
              fontSize:
                  32, // ใช้ขนาดฟอนต์คงที่เพื่อให้ดูง่ายขึ้น และใกล้เคียงต้นฉบับ
              fontWeight: FontWeight.bold,
              color: Color(0xFF438883), // สีเขียวเข้มของข้อความ
            ),
            textAlign: TextAlign.center,
          ),
          const Text(
            'รายรับรายจ่าย',
            style: TextStyle(
              fontSize:
                  32, // ใช้ขนาดฟอนต์คงที่เพื่อให้ดูง่ายขึ้น และใกล้เคียงต้นฉบับ
              fontWeight: FontWeight.bold,
              color: Color(0xFF438883), // สีเขียวเข้มของข้อความ
            ),
            textAlign: TextAlign.center,
          ),

          // เว้นระยะก่อนปุ่ม
          const SizedBox(height: 30), // ปรับระยะให้เหมาะสม

          // ส่วนที่ 3: ปุ่ม "เริ่มต้นใช้งานแอปพลิเคชัน" (ElevatedButton มีเงา)
          // ผมกำหนดความกว้างประมาณ 70% และสูงคงที่ 60 เพื่อให้ดูเหมือนต้นฉบับ
          Center(
            child: SizedBox(
              width: size.width * 0.7,
              height: 60,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacementNamed(context, '/home');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF438883), // สีเขียวของปุ่ม
                  foregroundColor: Colors.white, // สีขาวของข้อความ
                  elevation:
                      25, // กำหนดค่าเงา (Elevation) ให้มีความฟุ้งและเห็นได้ชัด (ลองปรับค่าได้ตั้งแต่ 10-20)
                  shadowColor: const Color(0xFF438883).withOpacity(
                      0.5), // กำหนดสีเงาให้เป็นโทนเดียวกับปุ่มเพื่อความนุ่มนวล
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30.0), // ขอบมน
                  ),
                ),
                child: const Text(
                  'เริ่มต้นใช้งานแอปพลิเคชัน',
                  style: TextStyle(
                    fontSize: 18, // ขนาดฟอนต์ของข้อความบนปุ่ม
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
