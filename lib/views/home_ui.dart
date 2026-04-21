import 'package:flutter/material.dart';
import 'package:flutter_money_tracking_app/views/money_balance_ui.dart';
import 'package:flutter_money_tracking_app/views/money_in_ui.dart';
import 'package:flutter_money_tracking_app/views/money_out_ui.dart';

class HomeUI extends StatefulWidget {
  const HomeUI({super.key});

  @override
  State<HomeUI> createState() => _HomeUIState();
}

class _HomeUIState extends State<HomeUI> {
  int _selectedIndex = 1;

  final List<Widget> _pages = const [
    MoneyInUI(),
    MoneyBalanceUI(),
    MoneyOutUI(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _pages,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        // สไตล์แบบเรียบง่าย (Minimal Style)
        backgroundColor: Colors.white,
        selectedItemColor: const Color(0xFF458F8B), // สีหลักของแอป
        unselectedItemColor: Colors.grey.shade400,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        type: BottomNavigationBarType.fixed,
        elevation: 10,
        items: [
          BottomNavigationBarItem(
            icon: _buildStaticIcon(Icons.analytics_rounded, 0, Colors.green),
            label: 'เงินเข้า',
          ),
          BottomNavigationBarItem(
            icon: _buildStaticIcon(
                Icons.assessment_rounded, 1, const Color(0xFF458F8B)),
            label: 'สรุปยอด',
          ),
          BottomNavigationBarItem(
            icon: _buildStaticIcon(Icons.shopping_bag_rounded, 2, Colors.red),
            label: 'เงินออก',
          ),
        ],
      ),
    );
  }

  // ฟังก์ชันสร้างไอคอนแบบเรียบง่าย (ไม่มีอนิเมชั่น)
  Widget _buildStaticIcon(IconData iconData, int index, Color activeColor) {
    final bool isSelected = _selectedIndex == index;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Icon(
        iconData,
        size: isSelected
            ? 28
            : 24, // ปรับขนาดเล็กน้อยเมื่อเลือกเพื่อให้รู้ตำแหน่ง
        color: isSelected ? activeColor : Colors.grey.shade400,
      ),
    );
  }
}
