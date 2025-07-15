import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lostu/views/components/navbar.dart';
import 'package:lostu/views/data/constants.dart';
import 'package:lostu/views/data/notifiers.dart';
import 'package:lostu/views/pages/login_page.dart';

class Layout extends StatefulWidget {
  final bool auth;
  const Layout({super.key, this.auth = false});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return ValueListenableBuilder<int>(
          valueListenable: pageNotfier.page,
          builder: (context, pageNumber, child) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(title: const Text("Logo")),
                body: const Center(child: CircularProgressIndicator()),
                bottomNavigationBar: Navbar(),
              );
            }
            if (snapshot.hasData || widget.auth) {
              return Scaffold(
                appBar: AppBar(title: const Text("Logo")),
                body: pages.elementAt(pageNumber),
                bottomNavigationBar: Navbar(),
              );
            }
            return const LoginPage();
          },
        );
      },
    );
  }
}
