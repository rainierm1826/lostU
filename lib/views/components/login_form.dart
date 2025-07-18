import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lostu/services/auth_service.dart';
import 'package:lostu/services/user_provider.dart';
import 'package:lostu/views/layout.dart';
import 'package:provider/provider.dart';

class LoginForm extends StatefulWidget {
  const LoginForm({super.key});

  @override
  State<LoginForm> createState() => _LoginFormState();
}

class _LoginFormState extends State<LoginForm> {
  final TextEditingController _srCode = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final GoogleAuthService _authService = GoogleAuthService();

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final user = _authService.validateUser(
        _srCode.text.trim(),
        _password.text.trim(),
      );

      if (user != null) {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        userProvider.setUser(user);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Layout()),
        );
      } else {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Invalid SR-Code or password")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      key: _formKey,
      child: SingleChildScrollView(
        child: Column(
          children: [
            TextFormField(
              controller: _srCode,
              decoration: InputDecoration(
                labelText: "SR-Code",
                border: OutlineInputBorder(),
                prefixIcon: Icon(FontAwesomeIcons.envelope),
                hintText: "Enter your sr-code",
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.5),
                ),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Empty SR-Code';
                }
                if (value.length < 8) {
                  return 'Invalid SR-Code';
                }
                return null;
              },
            ),
            SizedBox(height: 24),
            TextFormField(
              obscureText: true,
              controller: _password,
              decoration: InputDecoration(
                labelText: "Password",
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.lock),
                hintText: "Enter your password",
                filled: true,
                fillColor: Colors.white,
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey, width: 1.5),
                ),
              ),
            ),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                onPressed: () {
                  _submitForm();
                },
                child: const Text("Sign In"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
