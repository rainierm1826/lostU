import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:lostu/views/data/constants.dart';
import 'package:lostu/views/data/notifiers.dart';

class AdminNavbar extends StatefulWidget {
  const AdminNavbar({super.key});

  @override
  State<AdminNavbar> createState() => _AdminNavbarState();
}

class _AdminNavbarState extends State<AdminNavbar> {
  @override
  Widget build(BuildContext context) {
    return CurvedNavigationBar(
      backgroundColor: Colors.transparent,
      color: Colors.red,
      buttonBackgroundColor: Colors.red,
      animationCurve: Curves.easeInOut,
      animationDuration: const Duration(milliseconds: 300),
      height: 60,
      index: pageNotfier.page.value,
      items: adminNavbarIcon,
      onTap: (index) {
        pageNotfier.changePage(index);
      },
    );
  }
}
