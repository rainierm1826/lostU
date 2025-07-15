import 'package:flutter/material.dart';
import 'package:lostu/views/components/navbar.dart';
import 'package:lostu/views/data/constants.dart';
import 'package:lostu/views/data/notifiers.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: pageNotfier.page,
      builder: (context, pageNumber, child) {
        return Scaffold(
          appBar: AppBar(title: const Text("Logo")),
          bottomNavigationBar: Navbar(),
          body: pages.elementAt(pageNumber),
        );
      },
    );
  }
}
