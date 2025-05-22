import 'package:flutter/material.dart';

class CustomBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavBar({
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        child: BottomNavigationBar(
          backgroundColor: Colors.white,
          currentIndex: currentIndex,
          selectedItemColor: const Color(0xFFFFA46E),
          unselectedItemColor: Colors.black.withOpacity(0.6),
          showSelectedLabels: false,
          showUnselectedLabels: false,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          onTap: onTap,
          items: List.generate(5, (index) {
            final icons = [
              Icons.home,
              Icons.bar_chart,
              Icons.access_time,
              Icons.attach_money,
              Icons.copy,
            ];

            return BottomNavigationBarItem(
              icon: AnimatedScale(
                scale: currentIndex == index ? 1.2 : 1.0,
                duration: const Duration(milliseconds: 300),
                curve: Curves.easeOut,
                child: Icon(icons[index]),
              ),
              label: '',
            );
          }),
        ),
      ),
    );
  }
}
