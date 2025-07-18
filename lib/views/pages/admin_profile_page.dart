import 'package:flutter/material.dart';
import 'package:lostu/services/auth_service.dart';
import 'package:lostu/services/user_provider.dart';
import 'package:provider/provider.dart';

class AdminProfilePage extends StatelessWidget {
  const AdminProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final GoogleAuthService authService = GoogleAuthService();
    final user = Provider.of<UserProvider>(context).user;
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundImage: NetworkImage(
                  authService.currentUser?.photoURL ?? user["photoURL"] ?? "",
                ),
              ),
              SizedBox(height: 16),
              Text(
                authService.currentUser?.displayName ??
                    user["displayName"] ??
                    "",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Merriweather',
                ),
              ),
              Text(
                authService.currentUser?.email ?? user["email"] ?? "",
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.normal,
                  color: Colors.black87,
                ),
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: () async {
                  await authService.signOut();
                  userProvider.setUser(null);
                },
                child: Text("Sign Out"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
