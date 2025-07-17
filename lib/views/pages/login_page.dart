import 'package:flutter/material.dart';
import 'package:lostu/views/components/google_button.dart';
import 'package:lostu/views/components/login_form.dart';
import 'package:lostu/views/components/or_divider.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.asset(
                  "assets/images/bsu-bg.png",
                  fit: BoxFit.cover,
                ),
              ),
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(height: 50),
                    SizedBox(
                      height: 50,
                      width: 50,
                      child: Image.asset("assets/images/bsu-logo.png"),
                    ),
                    const Text(
                      "LostU",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 30,
                        fontFamily: "Merriweather",
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        "Sign in to access your student portal and stay \n connected with Batangas State University.",
                        style: TextStyle(
                          color: Colors.black87,
                          fontFamily: "Merriweather",
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: LoginForm(),
                    ),
                    const OrDivider(),
                    const GoogleButton(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
