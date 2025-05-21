import 'package:flutter/material.dart';
import '../layout/main_layout.dart';          // ✅ import layout ที่เราสร้างไว้
import '../widgets/homecontent.dart';        // ✅ หน้าเนื้อหาหลักของ Home

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MainLayout(
      selectedIndex: 0,                      // ✅ หน้าแรกใน navbar
      body: HomeContent(),                   // ✅ เนื้อหาของหน้า Home
    );
  }
}
