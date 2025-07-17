import 'package:flutter/material.dart';

class Logo extends StatelessWidget {
  const Logo({super.key});

  @override
  Widget build(BuildContext context) {
    return Text(
      "LostU",
      style: TextStyle(
        color: Colors.white,
        fontFamily: 'Merriweather',
        fontSize: 30,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}
