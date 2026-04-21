import 'package:flutter/material.dart';
import 'package:flutter_money_tracking_app/views/splash_screen_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart'; // 🔹 สำคัญมาก: สำหรับจัดการภาษาไทย

// Import ไฟล์ UI ทั้งหมดจากโฟลเดอร์ views
import 'package:flutter_money_tracking_app/views/home_ui.dart';
import 'package:flutter_money_tracking_app/views/money_balance_ui.dart';
import 'package:flutter_money_tracking_app/views/money_in_ui.dart';
import 'package:flutter_money_tracking_app/views/money_out_ui.dart';
import 'package:flutter_money_tracking_app/views/splash_screen_ui.dart';
import 'package:flutter_money_tracking_app/views/welcome_ui.dart';

Future<void> main() async {
  // 1. ตรวจสอบว่า Flutter Binding พร้อมทำงาน
  WidgetsFlutterBinding.ensureInitialized();

  // 2. ตั้งค่า Locale ภาษาไทยเพื่อให้แสดงวันที่ "มกราคม, กุมภาพันธ์..." ได้ถูกต้อง
  await initializeDateFormatting('th', null);

  // 3. ตั้งค่า Supabase เชื่อมต่อฐานข้อมูล
  await Supabase.initialize(
    url: 'https://zvdkeypaxvfucuymopnr.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inp2ZGtleXBheHZmdWN1eW1vcG5yIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzM3ODcyMTMsImV4cCI6MjA4OTM2MzIxM30.KPy8DzXBbKezLfwf3drC_q6M55ET5T7ge_uVeFMWxaU',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Money Tracking App',
      debugShowCheckedModeBanner: false,

      // 4. ตั้งค่า Theme สีเขียว Teal และฟอนต์ Kanit ทั้งแอป
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF458F8B),
          primary: const Color(0xFF458F8B),
        ),
        textTheme: GoogleFonts.kanitTextTheme(Theme.of(context).textTheme),
      ),

      // 5. กำหนดหน้าเริ่มต้นเป็น SplashScreen
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreenUi(), // หน้าโหลดตอนเปิดแอป
        '/welcome': (context) => const WelcomeUi(), // หน้าแนะนำแอป
        '/home': (context) =>
            const HomeUI(), // หน้าหลัก (ที่มี Bottom Navigation)
        '/money_in': (context) => const MoneyInUI(), // หน้าบันทึกรายรับ
        '/money_out': (context) => const MoneyOutUI(), // หน้าบันทึกรายจ่าย
        '/money_balance': (context) =>
            const MoneyBalanceUI(), // หน้าสรุปยอดเงิน
      },
    );
  }
}
