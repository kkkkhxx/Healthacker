import 'package:flutter/material.dart';
import '../widgets/bottomnavbar.dart';

class MainLayout extends StatefulWidget {
  final int selectedIndex;
  final Widget body;

  const MainLayout({
    Key? key,
    required this.selectedIndex,
    required this.body,
  }) : super(key: key);

  @override
  _MainLayoutState createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  void _onItemTapped(int index) {
    if (index == 2) {
      Navigator.pushNamed(context, '/selectactivity');
    } else if (index != widget.selectedIndex) {
      // ✅ ใช้ route ที่กำหนดไว้ใน main.dart และแสดง default เป็น HomePage
      switch (index) {
        case 0:
          Navigator.pushReplacementNamed(context, '/homepage');
          break;
        case 1:
          Navigator.pushReplacementNamed(context, '/calendar');
          break;
        case 3:
          Navigator.pushReplacementNamed(context, '/chat');
          break;
        case 4:
          Navigator.pushReplacementNamed(context, '/profile');
          break;
        default:
          Navigator.pushReplacementNamed(context, '/homepage');
          break;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0B2B54),
      body: widget.body,
      bottomNavigationBar: BottomNavbar(
        selectedIndex: widget.selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}