import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:lostu/services/user_provider.dart';
import 'package:lostu/views/components/admin_navbar.dart';
import 'package:lostu/views/components/logo.dart';
import 'package:lostu/views/components/navbar.dart';
import 'package:lostu/views/data/constants.dart';
import 'package:lostu/views/data/notifiers.dart';
import 'package:lostu/views/pages/login_page.dart';
import 'package:provider/provider.dart';

class Layout extends StatefulWidget {
  const Layout({super.key});

  @override
  State<Layout> createState() => _LayoutState();
}

class _LayoutState extends State<Layout> {
  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        return ValueListenableBuilder<int>(
          valueListenable: pageNotfier.page,
          builder: (context, pageNumber, child) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Scaffold(
                appBar: AppBar(title: const Logo()),
                body: const Center(child: CircularProgressIndicator()),
                bottomNavigationBar: Navbar(),
              );
            }

            if (user != null && user["role"] == "admin") {
              return Scaffold(
                appBar: AppBar(title: const Logo()),
                body: adminPages.elementAt(pageNumber),
                bottomNavigationBar: AdminNavbar(),
              );
            }

            if (snapshot.hasData || user != null) {
              return Scaffold(
                appBar: AppBar(title: const Logo()),
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
