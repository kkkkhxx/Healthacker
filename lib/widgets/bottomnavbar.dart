import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';

class BottomNavbar extends StatelessWidget {
  final int selectedIndex;
  final Function(int) onItemTapped;

  BottomNavbar({required this.selectedIndex, required this.onItemTapped});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black12, // สีของเงา
            blurRadius: 30, // ความเบลอของเงา
            offset: Offset(0, 3), // การเลื่อนเงา
          ),
        ],
      ),
      child: BottomAppBar(
        color: Colors.white,
        shape: CircularNotchedRectangle(),
        notchMargin: 10.0,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(IconlyLight.home, 0),
            _buildNavItem(IconlyLight.calendar, 1),
            _buildNavItem(IconlyLight.plus, 2),
            _buildNavItem(IconlyLight.chat, 3),
            _buildNavItem(IconlyLight.profile, 4),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    return IconButton(
      icon: Icon(
        icon,
        color: selectedIndex == index ? Colors.blue : Colors.grey,
        size: 32,
      ),
      onPressed: () => onItemTapped(index),
    );
  }
}
