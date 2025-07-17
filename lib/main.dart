import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lostu/firebase_options.dart';
import 'package:lostu/services/user_provider.dart';
import 'package:lostu/views/data/constants.dart';
import 'package:lostu/views/layout.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(
    ChangeNotifierProvider(create: (_) => UserProvider(), child: const MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: redWhiteTheme,
      home: Layout(),
    );
  }
}
