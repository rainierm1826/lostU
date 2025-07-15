import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:lostu/views/data/constants.dart';
import 'package:lostu/views/data/notifiers.dart';

class Navbar extends StatefulWidget {
  const Navbar({super.key});

  @override
  State<Navbar> createState() => _NavbarState();
}

class _NavbarState extends State<Navbar> {
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
      items: navbarIcon,
      onTap: (index) {
        pageNotfier.changePage(index);
      },
    );
  }
}
