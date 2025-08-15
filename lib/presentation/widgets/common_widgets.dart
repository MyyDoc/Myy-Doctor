import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 50,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFF0A1A27),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildIcon(Icons.home_rounded, 0),
          _buildIcon(Icons.search, 1),
          _buildIcon(Icons.play_circle_outline_rounded, 2),
          _buildIcon(Icons.notifications_none_outlined, 3),
        ],
      ),
    );
  }

  Widget _buildIcon(IconData icon, int index) {
    return GestureDetector(
      onTap: () => onItemTapped(index),
      child: Icon(
        icon,
        size: 32,
        color: currentIndex == index ? Colors.white : Colors.grey,
      ),
    );
  }
}
