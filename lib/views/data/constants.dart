import 'package:flutter/material.dart';
import 'package:lostu/views/pages/add_page.dart';
import 'package:lostu/views/pages/home_page.dart';
import 'package:lostu/views/pages/profile_page.dart';

const List<Widget> navbarIcon = [
  Icon(Icons.add, size: 30, color: Colors.white),
  Icon(Icons.home, size: 30, color: Colors.white),
  Icon(Icons.person, size: 30, color: Colors.white),
];

const List<Widget> pages = [AddPage(), HomePage(), ProfilePage()];

final ThemeData redWhiteTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: Colors.red,
  scaffoldBackgroundColor: Colors.white,
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
    elevation: 2,
    centerTitle: true,
    titleTextStyle: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Colors.white,
    ),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Colors.red,
    selectedItemColor: Colors.white,
    unselectedItemColor: Colors.white70,
  ),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Colors.black, fontSize: 16),
    bodyMedium: TextStyle(color: Colors.black87),
  ),
  iconTheme: const IconThemeData(color: Colors.red),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: Colors.red,
    foregroundColor: Colors.white,
  ),
  colorScheme: ColorScheme.fromSwatch().copyWith(
    primary: Colors.red,
    secondary: Colors.redAccent,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.red,
      foregroundColor: Colors.white,
    ),
  ),
);
